/**
 * OpenShell gRPC client -- calls the OpenShell gateway directly
 * without ShoreGuard as a middleman.
 *
 * Uses dynamic proto loading via @grpc/proto-loader to avoid
 * needing a proto compilation step.
 */
import * as grpc from "@grpc/grpc-js";
import * as protoLoader from "@grpc/proto-loader";
import { resolve, dirname } from "path";
import { fileURLToPath } from "url";
const __dirname = dirname(fileURLToPath(import.meta.url));
const PROTO_PATH = resolve(__dirname, "../proto/openshell.proto");
let _client = null;
function getClient(endpoint) {
    if (_client)
        return _client;
    const packageDef = protoLoader.loadSync(PROTO_PATH, {
        keepCase: false,
        longs: String,
        enums: String,
        defaults: true,
        oneofs: true,
        includeDirs: [resolve(__dirname, "../proto")],
    });
    const proto = grpc.loadPackageDefinition(packageDef);
    _client = new proto.openshell.v1.OpenShell(endpoint, grpc.credentials.createInsecure());
    return _client;
}
export async function healthCheck(endpoint) {
    const client = getClient(endpoint);
    return new Promise((resolve) => {
        client.Health({}, { deadline: Date.now() + 5000 }, (err) => {
            resolve(!err);
        });
    });
}
export async function createSandbox(endpoint, opts) {
    const client = getClient(endpoint);
    const spec = {};
    if (opts.image) {
        spec.template = { image: opts.image };
    }
    if (opts.cpu || opts.memory) {
        spec.resources = {};
        if (opts.cpu)
            spec.resources.cpu = opts.cpu;
        if (opts.memory)
            spec.resources.memory = opts.memory;
    }
    if (opts.gpu)
        spec.gpu = true;
    if (opts.environment)
        spec.environment = opts.environment;
    const request = { spec };
    if (opts.name)
        request.name = opts.name;
    if (opts.labels)
        request.labels = opts.labels;
    return new Promise((resolve, reject) => {
        client.CreateSandbox(request, { deadline: Date.now() + 120000 }, (err, response) => {
            if (err)
                return reject(new Error(`CreateSandbox failed: ${err.message}`));
            const sb = response?.sandbox;
            resolve({
                name: sb?.metadata?.name || opts.name || "unknown",
                phase: sb?.status?.phase || "unknown",
            });
        });
    });
}
export async function waitForSandboxReady(endpoint, name, timeoutMs = 120000) {
    const client = getClient(endpoint);
    const start = Date.now();
    while (Date.now() - start < timeoutMs) {
        const phase = await new Promise((resolve, reject) => {
            client.GetSandbox({ name }, { deadline: Date.now() + 10000 }, (err, res) => {
                if (err)
                    return reject(err);
                resolve(res?.sandbox?.status?.phase || "unknown");
            });
        });
        if (phase === "RUNNING" || phase === "Running" || phase === "running")
            return;
        if (phase === "FAILED" || phase === "Failed") {
            throw new Error(`Sandbox ${name} failed to start`);
        }
        await new Promise((r) => setTimeout(r, 2000));
    }
    throw new Error(`Sandbox ${name} did not become ready within ${timeoutMs}ms`);
}
export async function execInSandbox(endpoint, name, command, opts) {
    const client = getClient(endpoint);
    return new Promise((resolve, reject) => {
        const deadline = Date.now() + ((opts?.timeoutSecs || 600) + 30) * 1000;
        let stdout = "";
        let stderr = "";
        let exitCode = -1;
        const stream = client.ExecSandbox({
            name,
            command,
            environment: opts?.env || {},
            timeout_seconds: opts?.timeoutSecs || 600,
        }, { deadline });
        stream.on("data", (chunk) => {
            if (chunk.stdout)
                stdout += chunk.stdout;
            if (chunk.stderr)
                stderr += chunk.stderr;
            if (chunk.exitCode !== undefined && chunk.exitCode !== null) {
                exitCode = chunk.exitCode;
            }
            if (chunk.exit_code !== undefined && chunk.exit_code !== null) {
                exitCode = chunk.exit_code;
            }
        });
        stream.on("end", () => {
            resolve({ stdout, stderr, exitCode });
        });
        stream.on("error", (err) => {
            if (stdout || stderr) {
                resolve({ stdout, stderr, exitCode });
            }
            else {
                reject(new Error(`ExecSandbox failed: ${err.message}`));
            }
        });
    });
}
export async function deleteSandbox(endpoint, name) {
    const client = getClient(endpoint);
    return new Promise((resolve, reject) => {
        client.DeleteSandbox({ name }, { deadline: Date.now() + 30000 }, (err) => {
            if (err && err.code !== 5 /* NOT_FOUND */) {
                return reject(new Error(`DeleteSandbox failed: ${err.message}`));
            }
            resolve();
        });
    });
}
export async function listSandboxes(endpoint) {
    const client = getClient(endpoint);
    return new Promise((resolve, reject) => {
        client.ListSandboxes({}, { deadline: Date.now() + 10000 }, (err, res) => {
            if (err)
                return reject(err);
            const items = (res?.sandboxes || []).map((sb) => ({
                name: sb?.metadata?.name || "unknown",
                phase: sb?.status?.phase || "unknown",
            }));
            resolve(items);
        });
    });
}
