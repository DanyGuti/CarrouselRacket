#lang racket

;; Made by Daniel Gutiérrez Gómez A01068056
(define left-regex #rx"^[A-Z]1$") ; Out of bounds to the left when match
(define right-regex #rx"^[A-Z]5$") ; Out of bounds to the right when match
(define total-regex #rx"^(A|B|C|D|E)$") ; Total regex to search for row

;; Generate rows of letters: ("A", "B", "C", "D", "E", "F", "G", "H", "I", "J")
(define generate-row
  (lambda (inventory)
    (map car inventory)))

;; Generate the rows associated to a certain letter
(define generate-rows
  (lambda (inventory letter)
    (let ((rows (assoc letter inventory)))
      (if rows
          (cdr rows)
          '()))))

;; Matches a row and a col based on a letter and index
(define match-row-col
  (lambda (row-match index)
    (car(filter (lambda (row) (equal? (string->number index) (string->number(caddr row)))) row-match))))

;; Matches a row and a col based on a product
(define match-row-col-product
  (lambda (row-match string)
    (car(filter (lambda (row) (equal? (substring string 0 2) (car row))) row-match))))

;; Increase or decrease ASCII char based on passed char
(define (move-char c symbol)
  (integer->char (symbol (char->integer c) 1)))

;; Generate the right col
(define get-col-right
  (lambda (inventory)
    (map last (map cdr inventory))))

;; Generate the left col
(define get-col-left
  (lambda (inventory)
    (map (lambda (sublist) (last sublist))inventory)))

;; Minimum recursive calls
(define min-recursive-steps
  (lambda (list)(assoc(apply min (map car list))list)))

;; Replace window to string
(define (space-separated-string list)
  (string-join list " "))

;; Check for substrings
;; -1 substr(0, 1)
;; 0 substr(1, 2)
;; 1 substr(0, 2)
(define get-letter-index-window
    (lambda (window flag)
     (cond  ((equal? flag -1) (substring (car window) 0 1))
            ((equal? flag 0)(substring(car window) 1 2))
            ((equal? flag 1)(substring(car window) 0 2)))))

;; Check for substrings
;; -1 substr(0, 1)
;; 1 substr(0, 2)
(define get-product-letter-index
    (lambda (product flag)
     (cond ((equal? flag -1) (substring product 0 1))((equal? flag 1) (substring product 0 2)))))

;; Generate letter when rows and window passed
(define get-letter-match
    (lambda (row window)
      (car(filter(lambda (rows) (equal? rows (substring (car window) 0 1)))row))))

;; Move to the left or right based on passed flag
;; 0 go to the left
;; 1 go to the right
(define (move-left-right inventory window flag)
  (cond ((null? inventory) window) ; Look for row where window belongs 
        ((equal? flag 0)(look-inventory (get-letter-match (generate-row inventory) window)(- (string->number(caddr window)) 1)(generate-rows inventory (get-letter-match (generate-row inventory) window))))
        ((equal? flag 1)(look-inventory (get-letter-match (generate-row inventory) window)(+ (string->number(caddr window)) 1)(generate-rows inventory (get-letter-match (generate-row inventory) window))))
        (else (move-left-right (cdr inventory) window flag))))

;; Move up or down based on passed symbol
;; - go up
;; + go down
(define (move-up-down inventory window symbol)
    (cond ((null? inventory) window)
    ((and(equal? (substring (get-letter-match (generate-row inventory) window) 0 1) "A") (equal? symbol -))
    (match-row-col (generate-rows inventory "E") (caddr window)))
    ((and(equal? (substring (get-letter-match (generate-row inventory) window) 0 1) "E") (equal? symbol +))
    (match-row-col (generate-rows inventory "A") (caddr window)))
    (else(match-row-col (generate-rows inventory (string(move-char (string-ref(get-letter-match (generate-row inventory) window) 0) symbol)))(caddr window)))))

;; Look for same indexes in inventary
;; Return window at position
(define (look-inventory row index inventory)
  (cond ((null? inventory) null)
        ((equal?(string->number (caddar inventory)) index) ; Look for same indexes and rows return the last window
         (car inventory))
        (else (look-inventory row index (cdr inventory)))))

;; Min steps to get to a product
;; First go up, then down.
;; For each of those go left and right till out of bounds
;; If out of bounds, just return the other list with the counter
(define (min-steps-to-product rows product quantity inventory window symbol)
  (cond ((null? inventory) null)
        ((equal? (car rows) (get-product-letter-index product -1)) ; Identify the row where the product is
         (let ((min-up (min-to-row-up(get-letter-match (generate-row inventory) window) inventory (generate-rows inventory (get-letter-match (generate-row inventory) window)) window product))
               (min-down (min-to-row-down (get-letter-match (generate-row inventory) window) inventory (generate-rows inventory (get-letter-match (generate-row inventory) window)) window product)))
           (cond ((null? (cdr min-up))(min-down))
                 ((null? (cdr min-down))(min-up))
                 (else (add-retire-product product quantity (list min-up min-down) symbol)))))
        (else (min-steps-to-product (cdr rows) product quantity inventory window symbol))))

;; Retire product with the min possible steps to get
;; there from a starting position
(define (add-retire-product product quantity list-steps-window symbol)
  (cond ((null? product)
        (let ((result (symbol (caddr product) quantity)))
            (cond ((< result 0) (define modified-window (list (caadar list-steps-window) (car(cdadar list-steps-window)) (cadr(cdadar list-steps-window)) (number->string 0) ))
                 (display
                       (string-append "Queda: " (number->string 0) " del producto: " product " RELLENA EL INVENTARIO. Transacción hecha con los siguientes pasos: "
                                    (number->string (car(min-recursive-steps list-steps-window))) " " (string-join modified-window)))
                                     (newline)
                                     (modify-file "Inventory.txt" (number->string result) modified-window)
                     (newline))
                (else (result)))))
        (else (let ((result (symbol (string->number (cadr(cddadr (min-recursive-steps list-steps-window)))) quantity)))
          (cond (( < result 0) (define modified-window (list (caadar list-steps-window) (car(cdadar list-steps-window)) (cadr(cdadar list-steps-window)) (number->string 0) ))
                 (display
                       (string-append "Queda: " (number->string 0) " del producto: " product " RELLENA EL INVENTARIO. Transacción hecha con los siguientes pasos: "
                                    (number->string (car(min-recursive-steps list-steps-window))) " " (string-join modified-window)))
                                     (newline)
                                     (modify-file "Inventory.txt" (number->string result) modified-window)
                     (newline))                   ; Product name                ; Price                      ; index                          ; quantity 
                (else (define modified-window (list (caadar list-steps-window) (car(cdadar list-steps-window)) (cadr(cdadar list-steps-window)) (number->string result) ))
                 (display
                       (string-append "Queda: " (number->string result) " del producto: " product ". Transacción hecha con los siguientes pasos: "
                                    (number->string (car(min-recursive-steps list-steps-window))) " " (string-join modified-window)))
                                     (newline)
                                     (modify-file "Inventory.txt" (number->string result) modified-window)
                     (newline)))))))


;; Receive inventory and window
;; Calls move-up-down with - to move one cell up
(define (U inventory window)
  (cond ((null? inventory) null)
        (else (move-up-down inventory window -))))

;; Receive inventory and window
;; Calls move-up-down with + to move one cell down
(define (D inventory window)
  (cond ((null? inventory) null)
        (else (move-up-down inventory window +))))

;; Receive inventory and window
;; Calls move-left-right if not out of bounds with 0 to move left
(define (L inventory window)
  (cond ((null? inventory) null)
        ((has-match-left (get-col-left inventory) window) null)
        (else(move-left-right inventory window 0))))

;; Receive inventory and window
;; Calls move-left-right if not out of bounds with 1 to move right
(define (R inventory window)
  (cond ((null? inventory) null)
        ((has-match-right (get-col-right inventory) window) null)
        (else(move-left-right inventory window 1))))

;; Compare left col with window and regex
(define (has-match-left left-col window)
  (cond ((null? left-col)#f)
        ((regexp-match? left-regex (car window))#t)
        (else (has-match-left (cdr left-col) window))))

;; Compare right col with window and regex
(define (has-match-right right-col window)
  (cond ((null? right-col)#f)
        ((regexp-match? right-regex (car window))#t)
        (else (has-match-right (cdr right-col) window))))

;; Evaluate till the product is found to the right
;; Return the steps to get there
(define (min-check-cols-right inventory window product)
      (cond ((null? window)(list 0 window))
          ((equal? (get-letter-index-window window 1) (get-product-letter-index product 1)) (list 0 window))
    (else (let((result (min-check-cols-right inventory (R inventory window) product)))
          (cons(+ 1 (car result)) (cdr result))))))

;; Evaluate till the product is found to the right
;; Return the steps to get there
(define (min-check-cols-left inventory window product)
    (cond ((null? window)(list 0 window))
      ((equal? (get-letter-index-window window 1) (get-product-letter-index product 1)) (list 0 window))
    (else (let((result (min-check-cols-left inventory (L inventory window) product)))     
         (cons(+ 1 (car result)) (cdr result))))))


(define (modify-file file-path quantity window)
  ;; Open the input file
  (define input-port (open-input-file file-path))

  (define (replace-line line)
    (if (string=? (car line) (car window))
        (list (space-separated-string window))
        line))

  
  ;; Read and replace the desired line
  (define lines (list))
  (let loop ((line (read-line input-port)))
    (if (not (eof-object? line))
        (begin
          (set! lines (append lines (list (replace-line (string-split line " ")))))
          (loop (read-line input-port)))
        (void)))

  ;; Close the input file
  (close-input-port input-port)

  ;; Delete the output file if it already exists
  (if (file-exists? "Inventory.txt")
      (delete-file "Inventory.txt")
      #f)

  ;; Open the output file
  (define output-port (open-output-file "Inventory.txt"))

  ;; Write the modified list back to the file
  (for-each (lambda (line) (displayln (string-join line " ") output-port)) lines)

  ;; Close the output file
  (close-output-port output-port)
)


;; Evaluate till the product is found to the right
;; Return the steps to get there
;; returns left or right steps based on the results
(define (min-check-cols inventory window product)
  (cond ((equal? (get-letter-index-window window 1) (get-product-letter-index product 1)) (list 0 window))
        ((equal? (get-letter-index-window window 0) "1")
         (let ((result-right(min-check-cols-right inventory (R inventory window) product)))
           (cons (+ 1 (car result-right)) (cdr result-right))))
        ((equal? (get-letter-index-window window 0) "5")
         (let ((result-left(min-check-cols-left inventory (L inventory window) product)))
           (cons (+ 1 (car result-left)) (cdr result-left))))
        (else
         (let((result-right (min-check-cols-right inventory (R inventory window) product))
              (result-left (min-check-cols-left inventory (L inventory window) product)))
           (cond ((null? (cdr result-right)) (cons(+ 1 (car result-left)) (cdr result-left)))
                  (else (cons (+ 1 (car result-right)) (cdr result-right))))))))

;; Evaluate till the row is found upwards
;; return the sum of the steps and the state at the window
(define (min-to-row-up letter inventory row-belonged window product)
  (cond ((equal? (get-letter-index-window window -1) (get-product-letter-index product -1))(min-check-cols inventory window product))
  (else (let((result (min-to-row-up letter inventory row-belonged (U inventory window) product)))
          (cons(+ 1 (car result)) (cdr result))))))

;; Evaluate till the row is found upwards
;; return the sum of the steps and the state at the window
(define (min-to-row-down letter inventory row-belonged window product)
  (cond ((equal? (get-letter-index-window window -1) (get-product-letter-index product -1))(min-check-cols inventory window product))
  (else (let((result (min-to-row-down letter inventory row-belonged (D inventory window) product)))
          (cons(+ 1 (car result)) (cdr result))))))


(define (read-file file-path)
  (call-with-input-file file-path
    (lambda (port)
      (let loop ((line (read-line port))
                 (result '()))
        (if (eof-object? line)
            (reverse result)
            (loop (read-line port)
                  (cons (string-split line) result)))))))

(define file-lines (read-file "Inventory.txt"))

(define rows-A
  (lambda (rows)
    (let ((a-rows (filter (lambda (row) (equal? (substring (car row) 0 1) "A")) rows))
          (result '()))
      (set! result (cons "A" (map (lambda (sublist) (apply list sublist)) a-rows)))
      result)))
(define rows-B
  (lambda (rows)
    (let ((a-rows (filter (lambda (row) (equal? (substring (car row) 0 1) "B")) rows))
          (result '()))
      (set! result (cons "B" (map (lambda (sublist) (apply list sublist)) a-rows)))
      result)))
(define rows-C
  (lambda (rows)
    (let ((a-rows (filter (lambda (row) (equal? (substring (car row) 0 1) "C")) rows))
          (result '()))
      (set! result (cons "C" (map (lambda (sublist) (apply list sublist)) a-rows)))
      result)))
(define rows-D
  (lambda (rows)
    (let ((a-rows (filter (lambda (row) (equal? (substring (car row) 0 1) "D")) rows))
          (result '()))
      (set! result (cons "D" (map (lambda (sublist) (apply list sublist)) a-rows)))
      result)))
(define rows-E
  (lambda (rows)
    (let ((a-rows (filter (lambda (row) (equal? (substring (car row) 0 1) "E")) rows))
          (result '()))
      (set! result (cons "E" (map (lambda (sublist) (apply list sublist)) a-rows)))
      result)))

(define inventary (list (rows-A file-lines) (rows-B file-lines) (rows-C file-lines) (rows-D file-lines) (rows-E file-lines)))

(U inventary (list "A1" 100 "1" 15))
(min-steps-to-product (generate-row inventary) "C2" 2 inventary (list "A1" 100 "1") +)
(min-steps-to-product (generate-row inventary) "E5" 2 inventary (list "A1" 100 "1") -)