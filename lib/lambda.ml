open Core

module Expr = struct
  type var = string [@@deriving sexp]

  type t =
    | Unit
    | Str of string
    | Int of int
    | Binop of (int -> int -> int) * t * t
    | Var of var
    | App of t * t
    | Abs of var * t
    | Let of var * t * t
    | Seq of t * t
    | Show of t
  [@@deriving sexp]

  let var_equal = String.equal
  let cnt = ref 0

  let gen_sym prefix : var =
    incr cnt;
    prefix ^ "#" ^ (!cnt |> Int.to_string)
end

module rec Value : sig
  type t =
    | Unit
    | Int of int
    | Str of string
    | Clos of Expr.var * Expr.t * Env.t
  [@@deriving sexp]

  val string_of_t : t -> string
end = struct
  type t =
    | Unit
    | Int of int
    | Str of string
    | Clos of Expr.var * Expr.t * Env.t
  [@@deriving sexp]

  let string_of_t = function
    | Unit -> "()"
    | Int n -> Int.to_string n
    | Str s -> s
    | Clos _ as c -> c |> sexp_of_t |> Sexp.to_string
end

and Env : sig
  type t = (Expr.var, Value.t) List.Assoc.t [@@deriving sexp]

  val empty : t
  val add : t -> Expr.var -> Value.t -> t
  val find : t -> Expr.var -> Value.t
end = struct
  type t = (Expr.var, Value.t) List.Assoc.t [@@deriving sexp]

  let empty : t = []
  let add : t -> Expr.var -> Value.t -> t = List.Assoc.add ~equal:Expr.var_equal

  let find (env : t) (var : Expr.var) : Value.t =
    match List.Assoc.find ~equal:Expr.var_equal env var with
    | Some v -> v
    | None ->
        failwith
          ("Unbound variable " ^ var ^ " in environment "
          ^ (sexp_of_t env |> Sexp.to_string))
end

exception Show_fuel_exhausted

let show, refuel_show =
  let fuel = ref 100 in
  ( (fun v ->
      if !fuel > 0 then decr fuel else raise Show_fuel_exhausted;
      printf "%s" (Value.string_of_t v)),
    fun n -> fuel := n )

module DS = struct
  let rec eval (expr : Expr.t) (env : Env.t) : Value.t =
    match expr with
    | Unit -> Unit
    | Str s -> Str s
    | Int n -> Int n
    | Binop (op, e1, e2) -> (
        let v1 = eval e1 env in
        let v2 = eval e2 env in
        match (v1, v2) with
        | Int n1, Int n2 -> Int (op n1 n2)
        | _ -> failwith "type error")
    | Var x -> Env.find env x
    | App (e1, e2) -> (
        let v1 = eval e1 env in
        let v2 = eval e2 env in
        match v1 with
        | Clos (x, body, env) -> eval body (Env.add env x v2)
        | _ -> failwith "type error")
    | Abs (x, body) -> Clos (x, body, env)
    | Let (x, e, body) ->
        let v = eval e env in
        eval body (Env.add env x v)
    | Seq (e1, e2) ->
        eval e1 env |> ignore;
        eval e2 env
    | Show e ->
        let v = eval e env in
        show v;
        Unit
end

module CPS = struct
  let rec trans : Expr.t -> Expr.t =
    let open Expr in
    function
    | Unit ->
        let ret = gen_sym "k" in
        Abs (ret, App (Var ret, Unit))
    | Int n ->
        let ret = gen_sym "k" in
        Abs (ret, App (Var ret, Int n))
    | Str s ->
        let ret = gen_sym "k" in
        Abs (ret, App (Var ret, Str s))
    | Binop (op, e1, e2) ->
        let e1' = trans e1
        and e2' = trans e2
        and n1 = gen_sym "n"
        and n2 = gen_sym "n"
        and ret = gen_sym "k" in
        let work = Binop (op, Var n1, Var n2) in
        Abs (ret, App (e1', Abs (n1, App (e2', Abs (n2, App (Var ret, work))))))
    | Var x ->
        let ret = gen_sym "k" in
        Abs (ret, App (Var ret, Var x))
    | App (e1, e2) ->
        let e1' = trans e1
        and e2' = trans e2
        and f = gen_sym "f"
        and v = gen_sym "v"
        and ret = gen_sym "k" in
        let work = App (Var f, Var v) in
        Abs (ret, App (e1', Abs (f, App (e2', Abs (v, App (work, Var ret))))))
    | Abs (x, e) ->
        let e' = trans e and ret = gen_sym "k" in
        Abs (ret, App (Var ret, Abs (x, e')))
    | Let (x, e1, e2) ->
        let desugared = App (Abs (x, e2), e1) in
        trans desugared
    | Seq (e1, e2) ->
        let desugared = App (Abs (gen_sym "f", e2), e1) in
        trans desugared
    | Show e ->
        let e' = trans e and v = gen_sym "v" and ret = gen_sym "k" in
        let work = Show (Var v) in
        Abs (ret, App (e', Abs (v, App (Var ret, work))))

  let eval (expr : Expr.t) (env : Env.t) : Value.t =
    let open Expr in
    let ret = gen_sym "k" and cps = trans expr in
    DS.eval (App (cps, Abs (ret, Var ret))) env
end
