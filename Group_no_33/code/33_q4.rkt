#lang racket/base

; my-length: counts the top-level elements of a list.
; Arguments: lst, a proper list (atoms or sublists). Returns an integer >= 0.
; Tail-recursive: the named let carries the running count in an accumulator.
(define (my-length lst)
  (let loop ((rest lst) (count 0))
    (if (null? rest)
        count
        (loop (cdr rest) (+ count 1)))))