declare const TYPE_BOOL = 0;
declare const TYPE_STRING = 1;
declare const TYPE_NUMBER = 2;

declare interface Convar<T> {
    get(): T;
    set(val: T): void;
}

declare interface ConvarMeta {
    name: string;
    description: string;
}

declare function DefineConvar<T>(type: number, key: string, name?: string, description?: string, default_val?: any): Convar<T>;
declare function GetConvars(): string[];
declare function GetConvarMeta(key: string): ConvarMeta|null;