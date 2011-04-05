
module type SHOW = sig
  type t
  val show : t -> string
end

module Show :
  functor (P : SHOW) -> sig
    type t = P.t
    val show : P.t -> string
  end

module Show_bool : sig
  type t = bool
  val show : bool -> string
end

module Show_char : sig
  type t = char
  val show : char -> string
end

module Show_string : sig
  type t = string
  val show : string -> string
end

module Show_int : sig
  type t = int
  val show : int -> string
end

module Show_float : sig
  type t = float
  val show : float -> string
end

module Show_pair :
  functor (Fst : SHOW) ->
    functor (Snd : SHOW) ->
      sig
        type t = Fst.t * Snd.t
        val show : Fst.t * Snd.t -> string
      end

module Show_triple :
  functor (Fst : SHOW) ->
    functor (Snd : SHOW) ->
      functor (Trd : SHOW) ->
        sig
          type t = Fst.t * Snd.t * Trd.t
          val show :
            Fst.t * Snd.t * Trd.t -> string
        end

module Show_list :
  functor (Elt : SHOW) ->
    sig
      type t = Elt.t list
      val show : Elt.t list -> string
    end


module type ARBITRARY = sig
  type t
  val arbitrary : t QuickCheck_gen.gen
end

module Arbitrary_unit : sig
  type t = unit
  val arbitrary : unit QuickCheck_gen.gen
end

module Arbitrary_bool : sig
  type t = bool
  val arbitrary : bool QuickCheck_gen.gen
end

module Arbitrary_char : sig
  type t = char
  val arbitrary : char QuickCheck_gen.gen
end

module Arbitrary_string : sig
  type t = string
  val arbitrary : string QuickCheck_gen.gen
end

module Arbitrary_int : sig
  type t = int
  val arbitrary : int QuickCheck_gen.gen
end

module Arbitrary_float : sig
  type t = float
  val arbitrary : float QuickCheck_gen.gen
end

module Aribitrary_pair :
  functor (Fst : ARBITRARY) ->
    functor (Snd : ARBITRARY) ->
      sig
        type t = Fst.t * Snd.t
        val arbitrary : (Fst.t * Snd.t) QuickCheck_gen.gen
      end

module Aribitrary_triple :
  functor (Fst : ARBITRARY) ->
    functor (Snd : ARBITRARY) ->
      functor (Trd : ARBITRARY) ->
        sig
          type t = Fst.t * Snd.t * Trd.t
          val arbitrary : (Fst.t * Snd.t * Trd.t) QuickCheck_gen.gen
        end

module Arbitrary_list :
  functor (Elt : ARBITRARY) ->
    sig
      type t = Elt.t list
      val arbitrary : Elt.t list QuickCheck_gen.gen
    end


type result = {
  ok : bool option;
  stamp : string list;
  arguments : string list;
}

type property = Prop of result QuickCheck_gen.gen

val nothing : result

val result : result -> property

module type TESTABLE = sig
  type t
  val property : t -> property
end

module Testable_unit : sig
  type t = unit
  val property : unit -> property
end

module Testable_bool : sig
  type t = bool
  val property : bool -> property
end

module Testable_result : sig
  type t = result
  val property : result -> property
end

module Testable_property : sig
  type t = property
  val property : 'a -> 'a
end

module Evaluate :
  functor (T : TESTABLE) -> sig
    val evaluate : T.t -> result QuickCheck_gen.gen
  end

module ForAll :
  functor (S : SHOW) ->
    functor (T : TESTABLE) ->
      sig
        module E : sig val evaluate : T.t -> result QuickCheck_gen.gen end
        val forAll : S.t QuickCheck_gen.gen -> (S.t -> T.t) -> property
      end

(* boo *)
module Testable_fun :
  functor (A : ARBITRARY) ->
    functor (S : SHOW with type t = A.t) ->
      functor (T : TESTABLE) ->
        sig
          module F : sig
              module E : sig
                val evaluate : T.t -> result QuickCheck_gen.gen
              end
              val forAll : S.t QuickCheck_gen.gen -> (S.t -> T.t) -> property
          end
          type t = A.t -> T.t
          val property : t -> property
        end

module Implies :
  functor (T : TESTABLE) -> sig
    val ( ==> ) : bool -> T.t -> property
  end

module Label :
  functor (T : TESTABLE) ->
    sig
      module E : sig
        val evaluate : T.t -> result QuickCheck_gen.gen
      end
      val label : string -> T.t -> property
    end

module Classify :
  functor (T : TESTABLE) -> sig
    module L : sig
      module E : sig
        val evaluate : T.t -> result QuickCheck_gen.gen
      end
      val label : string -> T.t -> property
    end
    val classify : bool -> string -> T.t -> property
    val trivial : bool -> T.t -> property
  end

module Collect :
  functor (S : SHOW) ->
    functor (T : TESTABLE) -> sig
      module L : sig
        module E : sig
          val evaluate : T.t -> result QuickCheck_gen.gen
        end
        val label : string -> T.t -> property
      end
      val collect : S.t -> T.t -> property
    end




type config = {
  maxTest : int;
  maxFail : int;
  size : int -> int;
  every : Format.formatter -> int * string list -> unit;
}

val quick : config
val verbose : config
val done_ : string -> int -> string list list -> unit
val tests : config ->
  result QuickCheck_gen.gen ->
  int ->
  int ->
  string list list ->
  unit

module Check :
  functor (T : TESTABLE) ->
    sig
      module E : sig
        val evaluate : T.t -> result QuickCheck_gen.gen
      end
      val check : config -> T.t -> unit
      val test : T.t -> unit
      val quickCheck : T.t -> unit
      val verboseCheck : T.t -> unit
    end

