open Core
open Cps_callcc_yinyang
open Lambda

let string_of_value (value : Value.t) : string =
  value |> Value.sexp_of_t |> Sexp.to_string_hum

let string_of_expr (expr : Expr.t) : string =
  expr |> Expr.sexp_of_t |> Sexp.to_string_hum

let driver ?(env : Env.t = Env.empty) (expr : Expr.t) : unit =
  printf "DS:\t%s\n" (string_of_expr expr);
  let expr' = CPS.trans expr in
  printf "CPS:\t%s\n" (string_of_expr expr');
  match CPS.eval expr env with
  | v -> printf "CPS result:\t%s\n" (string_of_value v)
  | exception Show_fuel_exhausted -> printf "...\n"

let callcc =
  Expr.(
    Abs
      ( "f",
        Abs
          ( "cc",
            App
              ( App (Var "f", Abs ("x", Abs ("k", App (Var "cc", Var "x")))),
                Var "cc" ) ) ))

let env_callcc =
  let open Env in
  let x, e = match callcc with Abs (x, e) -> (x, e) | _ -> assert false in
  let clos = Value.Clos (x, e, empty) in
  add empty "call/cc" clos

let yin_yang =
  Expr.(
    Let
      ( "yin",
        App
          ( Abs ("cc", Seq (Show (Str "@"), Var "cc")),
            App (Var "call/cc", Abs ("c", Var "c")) ),
        Let
          ( "yang",
            App
              ( Abs ("cc", Seq (Show (Str "*"), Var "cc")),
                App (Var "call/cc", Abs ("c", Var "c")) ),
            App (Var "yin", Var "yang") ) ))

let () = driver yin_yang ~env:env_callcc
