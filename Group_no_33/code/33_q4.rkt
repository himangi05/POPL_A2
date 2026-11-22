#lang racket/base

; my-length: counts the top-level elements of a list.
; Arguments: lst, a proper list (atoms or sublists). Returns an integer >= 0.
; Tail-recursive: the named let carries the running count in an accumulator.
(define (my-length lst)
  (let loop ((rest lst) (count 0))
    (if (null? rest)
        count
        (loop (cdr rest) (+ count 1)))))


; my-reverse: helper that returns lst with its elements in reverse order.
; Arguments: lst, a proper list. Returns a new list. Tail-recursive (accumulator).
(define (my-reverse lst)
  (let loop ((rest lst) (acc '()))
    (if (null? rest)
        acc
        (loop (cdr rest) (cons (car rest) acc)))))

; my-map: applies f to each element of lst, left to right, and returns the list of results.
; Arguments: f, a function of one argument; lst, a proper list. Returns a new list of the same length.
; Tail-recursive: results are accumulated in reverse and turned around once at the end,
; so it works on very long lists (the call stack does not grow with the list length).
(define (my-map f lst)
  (let loop ((rest lst) (acc '()))
    (if (null? rest)
        (my-reverse acc)
        (loop (cdr rest) (cons (f (car rest)) acc)))))

; insert-if-short: inserts x at the front of every list whose length is less than n,
; at every level of nesting, including the top-level list.
; Arguments: x, any atom; lst, a (possibly nested) list of atoms and lists, no dotted pairs;
; n, an integer >= 0. Returns a new list; lst itself is not changed.
; The length of each list is measured on the ORIGINAL list, before any insertion, using my-length.
; Sublists are processed first with my-map; atoms are left as they are.
(define (insert-if-short x lst n)
  (let ((processed
         (my-map (lambda (e)
                   (if (or (pair? e) (null? e))
                       (insert-if-short x e n)
                       e))
                 lst)))
    (if (< (my-length lst) n)
        (cons x processed)
        processed)))