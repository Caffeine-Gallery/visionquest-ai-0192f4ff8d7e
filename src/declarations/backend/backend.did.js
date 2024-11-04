export const idlFactory = ({ IDL }) => {
  const Result = IDL.Variant({
    'ok' : IDL.Record({ 'processedImageData' : IDL.Vec(IDL.Nat8) }),
    'err' : IDL.Text,
  });
  return IDL.Service({
    'processImage' : IDL.Func([IDL.Vec(IDL.Nat8)], [Result], []),
  });
};
export const init = ({ IDL }) => { return []; };
