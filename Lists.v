(* ix:2I7 *)

Require Export Basics.

Module NatList.

Inductive natprod : Type :=
  pair : nat -> nat -> natprod.

Definition fst (p : natprod) : nat :=
  match p with
    pair x _ => x
  end.

Definition snd (p : natprod) : nat :=
  match p with
    pair _ y => y
  end.

Notation "( x , y )" := (pair x y).

Definition fst' (p : natprod) : nat :=
  match p with
  | (x,y) => x
  end.

Definition snd' (p : natprod) : nat :=
  match p with
  | (x,y) => y
  end.

Definition swap_pair (p : natprod) : natprod :=
  match p with
    (x, y) => (y, x)
  end.

Theorem snd_fst_is_swap : forall (p : natprod),
  (snd p, fst p) = swap_pair p.
  Proof.
    intro p.
    destruct p as [x y].
    reflexivity.
  Qed.

Theorem fst_swap_is_snd : forall (p : natprod),
  fst (swap_pair p) = snd p.
  Proof.
    intro p.
    destruct p as [x y].
    reflexivity.
  Qed.

Inductive natlist : Type :=
| nil : natlist
| cons : nat -> natlist -> natlist.


Notation "x :: l" := (cons x l) (at level 60, right associativity).
Notation "[ ]" := nil.
Notation "[ x , .. , y ]" := (cons x .. (cons y nil) ..).

Check [1,2,3].
Check 1::2::3::nil.
Check (cons 1 (cons 2 (cons 3 nil))).

Fixpoint repeat (n count : nat) : natlist  :=
  match count with
    | O => []
    | S count' => n::(repeat n count')
  end.

(*  repeat 0 3
   =>  repeat 0 (S (S (S O)))
   =>  0::(repeat 0 (S (S O)))
   => 0::0::(repeat 0 (S O))
   => 0::0::0::(repeat 0 0)
   => 0::0::0::[]
   ~ [0,0,0]
*)

Fixpoint length (l : natlist) : nat :=
  match l with
    | nil => O
    | h :: t => S (length t)
  end.

(* length [1,2]
   (* [1,2] = 1::[2] = 1::2::nil = cons 1 (cons 2 nil) *)
   => S ( length [2] )
   => S ( S (length nil))
   => (S (S O)
*)

Eval simpl in length [1,2].


(* app [1,2,3,4] [3,4] = [1,2,3,4] *)
Fixpoint app (l1 l2 : natlist) :=
  match l1 with
    | [] => l2
    | h::t => cons h (app t l2)
  end.

Notation "x ++ y" := (app x y)
                     (right associativity, at level 60).

Eval simpl in  [1,2] ++ [3,4].

Definition hd (default: nat) (l:natlist) :=
  match l with
    | nil => default
    | h::t => h
  end.

Definition tl (l:natlist) : natlist :=
  match l with
    | [] => []
    | _::t => t
  end.

Fixpoint nonzeros (l:natlist) : natlist :=
  match l with
    | [] => []
    | O::t => nonzeros t
    | h::t => h::(nonzeros t)
  end.

Example test_nonzeros: nonzeros [0,1,0,2,3,0,0] = [1,2,3].
Proof.
  reflexivity.
Qed.

Fixpoint oddmembers (l:natlist) : natlist  :=
  match l with
    | [] => []
    | h::t => match (oddb h) with
                | true =>  h::(oddmembers t)
                | false => oddmembers t
              end
  end.

Example test_oddmembers: oddmembers [0,1,0,2,3,0,0] = [1,3].
Proof.
  reflexivity.
Qed.

Fixpoint countoddmembers (l:natlist) : nat :=
  match l with
    | [] => O
    | h::t => match (oddb h) with
                | true =>  S (countoddmembers t)
                | false => countoddmembers t
              end
  end.

(* "if" can be used with any two-constuctor type such as "bool" *)
Fixpoint countoddmembers' (l:natlist) : nat :=
  match l with
    | [] => O
    | h::t => if (oddb h) then S (countoddmembers t) else countoddmembers t
  end.

Example test_countoddmembers1: countoddmembers [1,0,3,1,4,5] = 4.
Proof.
  reflexivity.
Qed.

(* HOMEWORK *)
(* Dragan's solution *)   

Fixpoint alternate (l1 l2 : natlist) : natlist :=
  match l2 with
    | [] => l1
    | h2::t2 => match l1 with
                  | [] => l2
                  | h1 :: t1 => h1 :: h2 :: (alternate t1 t2)
                end
  end.


Example test_alternate1: alternate [1,2,3] [4,5,6] = [1,4,2,5,3,6].
Proof.
  reflexivity.
Qed.
Example test_alternate2: alternate [1] [4,5,6] = [1,4,5,6].
Proof.
  reflexivity.
Qed.
Example test_alternate3: alternate [1,2,3] [4] = [1,4,2,3].
Proof.
  reflexivity.
Qed.
Example test_alternate4: alternate [] [20,30] = [20,30].
Proof.
  reflexivity.
Qed.

Definition bag := natlist.

Fixpoint count (v:nat) (s:bag) : nat :=
  match s with
    | [] => O
    | h::t => if beq_nat v h then S (count v t) else count v t
  end.

Example test_count1: count 1 [1,2,3,1,4,1] = 3.
Proof.
  reflexivity.
Qed.

Example test_count2: count 6 [1,2,3,1,4,1] = 0.
Proof.
  reflexivity.
Qed.


Definition sum : bag -> bag -> bag :=  app.

Example test_sum1: count 1 (sum [1,2,3] [1,4,1]) = 3.
Proof.
  reflexivity.
Qed.


Definition add (v:nat) (b:bag) := cons v b.

Example test_add1: count 1 (add 1 [1,4,1]) = 3.
reflexivity.
Qed.

Example test_add2: count 5 (add 1 [1,4,1]) = 0.
reflexivity.
Qed.

Definition member (v:nat) (s:bag) : bool :=
  negb (beq_nat (count v s) O).

Example test_member1: member 1 [1,4,1] = true.
reflexivity.
Qed.

Example test_member2: member 2 [1,4,1] = false.
  reflexivity.
Qed.

Fixpoint remove_one (v:nat) (s:bag) : bag :=
  match s with
    | [] => []
    | h::t => if (beq_nat h v) then t else h::(remove_one v t)
  end.

Example test_remove_one1: count 5 (remove_one 5 [2,1,5,4,1]) = 0.
reflexivity.
Qed.
Example test_remove_one2: count 5 (remove_one 5 [2,1,4,1]) = 0.
reflexivity.
Qed.
Example test_remove_one3: count 4 (remove_one 5 [2,1,4,5,1,4]) = 2.
reflexivity.
Qed.
Example test_remove_one4:
  count 5 (remove_one 5 [2,1,5,4,5,1,4]) = 1.
reflexivity.
Qed.

Fixpoint remove_all (v:nat) (s:bag) : bag :=
  match s with
    | [] => []
    | h::t => if (beq_nat h v) then (remove_all v t) else h::(remove_all v t)
  end.

Example test_remove_all1: count 5 (remove_all 5 [2,1,5,4,1]) = 0.
reflexivity.
Qed.

Example test_remove_all2: count 5 (remove_all 5 [2,1,4,1]) = 0.
reflexivity.
Qed.

Example test_remove_all3: count 4 (remove_all 5 [2,1,4,5,1,4]) = 2.
reflexivity.
Qed.

Example test_remove_all4: count 5 (remove_all 5 [2,1,5,4,5,1,4,5,1,4]) = 0.
reflexivity.
Qed.

Fixpoint subset (s1:bag) (s2:bag) : bool :=
  match s1 with
    | [] => true
    | h::t => if (member h s2) then (subset t (remove_one h s2)) else false
  end.


Example test_subset1: subset [1,2] [2,1,4,1] = true.
Proof.
reflexivity.
Qed.

(* subset cannot be longer than the set *)
Example test_subset2: subset [1,2,2] [4,1] = false.
reflexivity.
Qed.

(* permutation *)
Example test_subset3: subset [1,2,2] [2,1,2] = true.
reflexivity.
Qed.

(* HOMEWORK
Exercise: 3 stars, recommended (bag_theorem)

Write down an interesting theorem about bags involving the functions
count and add, and prove it. Note that, since this problem is somewhat
open-ended, it's possible that you may come up with a theorem which is
true, but whose proof requires techniques you haven't learned
yet. Feel free to ask for help if you get stuck!
*)

(* Dragan's solution *)

Theorem p_n_count_add : forall (p : nat) (s:bag),
  S (count p s) = count p (add p s).
  Proof.
    intros p s.
    simpl.
    rewrite <- beq_nat_refl.
    reflexivity.
Qed.

(* bojan's solution *)

Theorem homework3: forall (n m:nat) (b:bag),
  (beq_nat n m) = false -> beq_nat (count n b) (count n (add m b)) = true.
Proof.
  destruct b as [| n' b'].
  intro.
  simpl.
  rewrite H.
  reflexivity.
  intro.
  simpl.
  rewrite H.
  rewrite <- beq_nat_refl.
  reflexivity.
Qed.

Theorem nil_app : forall l:natlist,
  [] ++ l = l.
Proof.
  reflexivity.
Qed.

Theorem tl_length_pred : forall l:natlist,
  pred (length l) = length (tl l).
  Proof.
    destruct l as [| n l'].
    reflexivity.
    reflexivity.
  Qed.

Theorem app_ass : forall l1 l2 l3 : natlist,
  (l1 ++ l2) ++ l3 = l1 ++ (l2 ++ l3).
Proof.
  intros l1 l2 l3.
  induction l1 as [| n l1'].
  reflexivity.
  simpl.
  rewrite -> IHl1'.
  reflexivity.
Qed.

Theorem app_length : forall l1 l2 : natlist,
  length (l1 ++ l2) = (length l1) + (length l2).
  Proof.
    intros l1 l2.
    induction l1 as [|n l'].
    reflexivity.
    simpl.
    rewrite -> IHl'.
    reflexivity.
  Qed.

Fixpoint snoc (l:natlist) (v:nat) : natlist :=
  match l with
    | [] => [v]
    | h :: t => h :: (snoc t v)
  end.

Fixpoint rev (l:natlist) : natlist :=
  match l with
    | [] => []
    | h :: t => (snoc (rev t) h)
  end.

Lemma length_snoc: forall (l:natlist) (n:nat),
  length (snoc l n) = S (length l).
Proof.
  intros l n.
  induction l as [| n' l' ].
  reflexivity.
  simpl.
  rewrite -> IHl'.
  reflexivity.
Qed.

Theorem rev_length : forall l : natlist,
  length (rev l) = length l.
Proof.
  intro l.
  induction l as [| n l'].
  reflexivity.
  simpl.
  rewrite -> length_snoc.
  rewrite -> IHl'.
  reflexivity.
Qed.

Theorem app_nil_end : forall l : natlist,
  l ++ [] = l.
Proof.
  intro l.
  induction l as [|n l'].
  reflexivity.
  simpl.
  rewrite -> IHl'.
  reflexivity.
Qed.

Theorem rev_snoc : forall (n:nat) (l:natlist),
  rev (snoc l n)   = n :: (rev l).
Proof.
  intros n l.
  induction l as [| n' l'].
  reflexivity.
  simpl.
  rewrite -> IHl'.
  reflexivity.
Qed.

Theorem rev_involutive : forall l : natlist,
  rev (rev l) = l.
  Proof.
    intro l.
    induction l as [| n l'].
    reflexivity.
    simpl.
    rewrite -> rev_snoc.
    rewrite IHl'.
    reflexivity.
  Qed.


(* Homework *)
Lemma snoc_app: forall (l1 l2:natlist) (n:nat),
 snoc (l1 ++ l2) n = l1 ++ snoc l2 n.
Proof.
  intros l1 l2 n.
  induction l1.
  reflexivity.
  simpl.
  rewrite IHl1.
  reflexivity.
Qed.

Theorem distr_rev : forall l1 l2 : natlist,
  rev (l1 ++ l2) = (rev l2) ++ (rev l1).
Proof.
  intros l1 l2.
  induction l1 as [| n l1'].
  simpl.
  rewrite -> app_nil_end.
  reflexivity.
  simpl.
  rewrite -> IHl1'.
  rewrite -> snoc_app.
  reflexivity.
Qed.
  
Theorem snoc_append : forall (l:natlist) (n:nat),
  snoc l n = l ++ [n].
Proof.
  intros l n.
  induction l.
  reflexivity.
  simpl.
  rewrite IHl.
  reflexivity.
Qed.

Theorem app_ass4 : forall l1 l2 l3 l4 : natlist,
  l1 ++ (l2 ++ (l3 ++ l4)) = ((l1 ++ l2) ++ l3) ++ l4.
  Proof.
    intros l1 l2 l3 l4.
    rewrite <- app_ass.
    rewrite <- app_ass.
    reflexivity.
  Qed.


Lemma nonzeros_length : forall l1 l2 : natlist,
  nonzeros (l1 ++ l2) = (nonzeros l1) ++ (nonzeros l2).
Proof.
  intros l1 l2.
  induction l1 as [| n l1'].
  reflexivity.
  destruct n as [| n'].
  simpl.
  rewrite -> IHl1'.
  reflexivity.
  simpl.
  rewrite -> IHl1'.
  reflexivity.
Qed.

Theorem count_member_nonzero : forall (s : bag),
  ble_nat 1 (count 1 (1 :: s)) = true.
Proof.
  intro s.
  reflexivity.
Qed.

Theorem ble_n_Sn : forall n,
  ble_nat n (S n) = true.
Proof.
  intro n.
  induction n as [| n'].
  reflexivity.
  simpl.
  rewrite IHn'.
  reflexivity.
Qed.

Theorem remove_decreases_count: forall (s : bag),
  ble_nat (count 0 (remove_one 0 s)) (count 0 s) = true.
Proof.
  intros s.
  induction s as [| n s' ].
  reflexivity.
  destruct n.
  simpl.
  rewrite ble_n_Sn.
  reflexivity.
  simpl.
  rewrite IHs'.
  reflexivity.
Qed.



(* Homework *)
(** Write down an interesting theorem about bags involving the
    functions [count] and [sum], and prove it.
    *)

Lemma count_sum_distr: forall (s1 s2:bag) (n:nat),
  count n (sum s1 s2) = count n s1 + count n s2.
Proof.
  intros s1 s2 n.
  induction s1.
  reflexivity.
  simpl.
  destruct (beq_nat n n0).
  simpl.
  rewrite IHs1.
  reflexivity.
  rewrite IHs1.
  reflexivity.
Qed.

Theorem ble_nat_plus: forall (n1 n2:nat),
  ble_nat n1 (n1 + n2) = true.
  Proof.
  intros n1 n2.
  induction n1 as [|n1'].
  reflexivity.
  simpl.
  exact IHn1'.
Qed.

Theorem sum_increases_count: forall (s1 s2:bag) (n:nat),
  ble_nat (count n s1) (count n (sum s1 s2)) = true.
Proof.
  intros s1 s2 n.
  rewrite count_sum_distr.
  rewrite ble_nat_plus.
  reflexivity.
Qed.  
  

(* homework *)
(** Prove that the [rev] function is injective, that is,

[[
    forall (l1 l2 : natlist), rev l1 = rev l2 -> l1 = l2.
]]
*)

Theorem rev_injective: forall (l1 l2 : natlist),
  rev l1 = rev l2 -> l1 = l2.
Proof.
  intros l1 l2 H.
  rewrite <- rev_involutive. 
  rewrite <- H.
  rewrite  rev_involutive.
  reflexivity.
Qed.

Inductive natoption : Type :=
| None : natoption
| Some : nat -> natoption.

Fixpoint index_bad (n:nat) (l:natlist) : nat :=
  match l with
  | nil => 42  (* arbitrary! *)
  | a :: l' => match beq_nat n O with 
               | true => a 
               | false => index_bad (pred n) l' 
               end
  end.



Fixpoint index (n:nat) (l:natlist) : natoption :=
  match l with
  | nil => None
  | a :: l' => match beq_nat n O with 
               | true => Some a 
               | false => index (pred n) l' 
               end
  end.

Definition foo (l:natlist) : bool :=
  match index 5 l with
    | Some 3 => true
    | _ => false
  end.

Fixpoint index' (n:nat) (l:natlist) : natoption :=
  match l with
  | nil => None 
  | a :: l' => if beq_nat n O then Some a else index (pred n) l'
  end.

Definition option_elim (d : nat) (o : natoption) : nat :=
  match o with
  | Some n' => n'
  | None => d
  end.

Definition hd_opt (l : natlist) : natoption :=
  match l with 
    | [] => None
    | h :: t => Some h
  end.

Theorem option_elim_hd : forall (l:natlist) (default:nat),
  hd default l = option_elim default (hd_opt l).
Proof.
  intros l default.
  destruct l.
  reflexivity.
  reflexivity.
Qed.

Fixpoint beq_natlist (l1 l2 : natlist) : bool :=
  match l1, l2 with
    | [], [] => true
    | h1 :: t1, h2 :: t2 => if beq_nat h1 h2 then beq_natlist t1 t2 else false
    | _, _ => false
  end.

End NatList.