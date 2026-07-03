export interface SandboxInfo {
    name: string;
    phase: string;
}
export declare function healthCheck(endpoint: string): Promise<boolean>;
export declare function createSandbox(endpoint: string, opts: {
    name?: string;
    image?: string;
    cpu?: string;
    memory?: string;
    gpu?: boolean;
    environment?: Record<string, string>;
    labels?: Record<string, string>;
}): Promise<SandboxInfo>;
export declare function waitForSandboxReady(endpoint: string, name: string, timeoutMs?: number): Promise<void>;
export interface ExecResult {
    stdout: string;
    stderr: string;
    exitCode: number;
}
export declare function execInSandbox(endpoint: string, name: string, command: string[], opts?: {
    timeoutSecs?: number;
    env?: Record<string, string>;
}): Promise<ExecResult>;
export declare function deleteSandbox(endpoint: string, name: string): Promise<void>;
export declare function listSandboxes(endpoint: string): Promise<SandboxInfo[]>;
