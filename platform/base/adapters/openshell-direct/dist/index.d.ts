/**
 * Paperclip adapter for NVIDIA OpenShell -- runs agents in sandboxed containers.
 *
 * This adapter calls the OpenShell gateway's gRPC API directly (no ShoreGuard).
 * Each agent run:
 *   1. Creates (or reuses) an OpenShell sandbox pod
 *   2. Executes the agent command inside the sandbox
 *   3. Streams stdout/stderr back to Paperclip's run log
 *   4. Optionally cleans up the sandbox
 */
interface AdapterExecutionContext {
    runId: string;
    agent: {
        id: string;
        name: string;
        companyId: string;
    };
    runtime: any;
    config: Record<string, unknown>;
    context: Record<string, unknown>;
    onLog: (stream: "stdout" | "stderr", chunk: string) => Promise<void>;
    onSpawn?: (meta: {
        pid: number;
        processGroupId: number | null;
        startedAt: string;
    }) => Promise<void>;
}
interface AdapterExecutionResult {
    exitCode: number | null;
    signal: string | null;
    timedOut: boolean;
    summary?: string;
    errorMessage?: string;
    errorCode?: string;
}
interface AdapterEnvironmentTestContext {
    config: Record<string, unknown>;
}
interface AdapterEnvironmentTestResult {
    checks: Array<{
        code: string;
        level: string;
        passed: boolean;
        message: string;
    }>;
}
interface ServerAdapterModule {
    type: string;
    execute: (ctx: AdapterExecutionContext) => Promise<AdapterExecutionResult>;
    testEnvironment: (ctx: AdapterEnvironmentTestContext) => Promise<AdapterEnvironmentTestResult>;
    models: Array<{
        id: string;
        label: string;
    }>;
    agentConfigurationDoc: string;
}
export declare const openshellDirectAdapter: ServerAdapterModule;
export declare function createServerAdapter(): ServerAdapterModule;
export default openshellDirectAdapter;
