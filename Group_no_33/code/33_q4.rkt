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

; make-inserter: builds a function that inserts x at the front of every list whose length
; satisfies len-ok?, at every level of nesting, including the top-level list.
; Arguments: x, any atom; len-ok?, a function taking one number (a list's length) and
; returning true or false. Returns a function of one argument, a (possibly nested) list.
; The length is measured on the ORIGINAL list, before any insertion, using my-length.
; letrec lets the returned function call itself on every sublist.
(define (make-inserter x len-ok?)
  (letrec ((insert
            (lambda (lst)
              (let ((processed
                     (my-map (lambda (e)
                               (if (or (pair? e) (null? e))
                                   (insert e)
                                   e))
                             lst)))
                (if (len-ok? (my-length lst))
                    (cons x processed)
                    processed)))))
    insert))

; insert-if-short: inserts x at the front of every list whose length is less than n,
; at every level of nesting, including the top-level list.
; Arguments: x, any atom; lst, a (possibly nested) list of atoms and lists, no dotted pairs;
; n, an integer >= 0. Returns a new list; lst itself is not changed.
; Defined with make-inserter: the length test is (lambda (k) (< k n)).
(define (insert-if-short x lst n)
  ((make-inserter x (lambda (k) (< k n))) lst))

; print-insert-result: reads x, lst and n from standard input (in that order, with read),
; then prints (insert-if-short x lst n) with display, followed by a newline.
; Arguments: none. Prints nothing else (no prompts). let* makes the reading order explicit.
(define (print-insert-result)
  (let* ((x (read))
         (lst (read))
         (n (read)))
    (display (insert-if-short x lst n))
    (newline)))