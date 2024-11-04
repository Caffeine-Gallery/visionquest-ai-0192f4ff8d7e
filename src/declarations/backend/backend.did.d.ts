import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export type Result = {
    'ok' : { 'processedImageData' : Uint8Array | number[] }
  } |
  { 'err' : string };
export interface _SERVICE {
  'processImage' : ActorMethod<[Uint8Array | number[]], Result>,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
