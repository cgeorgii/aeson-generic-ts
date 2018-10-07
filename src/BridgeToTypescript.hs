module BridgeToTypescript where

import Bridge.Intermediate
import Typescript.Types

bridgeTypeToTSType :: BType -> TSType
bridgeTypeToTSType btype =
  case btype of
    BPrimitiveType bprim ->
      TSPrimitiveType $ bprimToTSPrim bprim
    BCollectionType bcollection ->
      case bcollection of
        BArray btypeInArray ->
          TSCollectionType $ TSArray (bridgeTypeToTSType btypeInArray)
    BOption btypeInOption ->
      TSCustomType $ TSOption (bridgeTypeToTSType btypeInOption)
    BConstructed typeName c ->
      case c of
        (BRecordConstructor fields) ->
            TSInterface typeName $ bfieldToTSField <$> fields
        (UnionConstructor _) -> TSAny


bprimToTSPrim :: BPrimitive -> TSPrimitive
bprimToTSPrim bprim =
  case bprim of
    BInt -> TSNumber
    BString -> TSString
    BBoolean -> TSBoolean

bfieldToTSField :: BField -> TSField
bfieldToTSField (BField (BFieldName fieldName ) btype) =
  TSField (Typescript.Types.FieldName fieldName) (bridgeTypeToTSType btype)
