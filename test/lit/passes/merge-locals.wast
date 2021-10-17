;; NOTE: Assertions have been generated by update_lit_checks.py and should not be edited.
;; RUN: wasm-opt %s --merge-locals -all -S -o - \
;; RUN:   | filecheck %s

(module
  ;; CHECK:      (func $ref-to-copy
  ;; CHECK-NEXT:  (local $copy anyref)
  ;; CHECK-NEXT:  (local $original anyref)
  ;; CHECK-NEXT:  (local.set $copy
  ;; CHECK-NEXT:   (local.get $original)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (local.get $copy)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (local.get $copy)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $ref-to-copy
    (local $copy anyref)
    (local $original anyref)
    (local.set $copy
      (local.get $original)
    )
    ;; Test that merge-locals support subtyping. Merge-locals wants to use the
    ;; same local in as many places, which simplies the pattern of local usage
    ;; and allows more opts later.
    ;; In this case, both gets can use $copy. The type of the locals is a
    ;; reference type, but it is the same type, and so the type is not a factor
    ;; here.
    (drop
      (local.get $original)
    )
    (drop
      (local.get $copy)
    )
  )

  (func $ref-to-copy-and-original-is-subtype
    (local $copy anyref)
    (local $original funcref)
    (local.set $copy
      (local.get $original)
    )
    ;; As above, but the original is a subtype. We prefer to use a more specific
    ;; type, and so we will *not* turn them both into $copy as we did above,
    ;; but rather turn them both into $original.
    (drop
      (local.get $original)
    )
    (drop
      (local.get $copy)
    )
  )

  (func $ref-to-copy-and-copy-is-subtype
    (local $copy anyref)
    (local $original funcref)
    (local.set $copy
      (local.get $original)
    )
    ;; As above, but the copy is a subtype. Again, prefer the specific type, so
    ;; we turn them both into $copy.
    (drop
      (local.get $original)
    )
    (drop
      (local.get $copy)
    )
  )

  ;; CHECK:      (func $ref-to-original (param $param i32)
  ;; CHECK-NEXT:  (local $copy anyref)
  ;; CHECK-NEXT:  (local $original anyref)
  ;; CHECK-NEXT:  (local.set $copy
  ;; CHECK-NEXT:   (local.get $original)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (local.get $original)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (local.get $param)
  ;; CHECK-NEXT:   (local.set $original
  ;; CHECK-NEXT:    (ref.null func)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (local.get $original)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $ref-to-original (param $param i32)
    (local $copy anyref)
    (local $original anyref)
    (local.set $copy
      (local.get $original)
    )
    ;; Another possible set exists to $original, which prevents using $copy for
    ;; both of the gets. However, we can use $original for them both.
    (drop
      (local.get $copy)
    )
    (if
      (local.get $param)
      (local.set $original
        (ref.null func)
      )
    )
    (drop
      (local.get $original)
    )
  )

  ;; casts
)

