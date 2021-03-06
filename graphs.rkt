#lang racket

(require plot)
(require "data-filtering.rkt")
(provide plot-2D plot-3D plot-statics)

(struct annotated-proc (base note)
   #:property prop:procedure
              (struct-field-index base))

;;(plot-2D list-of-datasets col1 col2) -> plot?
;; list-of-datasets: list of datasets that are lists of lists
;; col1: colmun of the data set to plot on the x-axis
;; col2: colmun of the data set to plot on the y-axis
;; regression: 'none make no linear regression appear on the plot all other values will

;;usage: (plot-2D (list Iris-virginica Iris-versicolor) petal-width petal-length 'none)

(define (plot-2D list-of-datasets col1 col2 regression)
  ;;count is used to make sure each dataset plotted has a different color
 (let ([regression-vals (make-linear-regression (merge-lists list-of-datasets) col1 col2)])
     (define (points-creator list-of-datasets col1 col2 list-of-points count)
        (if (null? list-of-datasets)
            (if (eqv? regression 'none)
                list-of-points
                (cons (function
                       (lambda (x) (+ (* (car regression-vals) x) (car (cdr regression-vals)))))
                      list-of-points))
            (points-creator (cdr list-of-datasets) col1 col2
                            (cons (points
                                   (foldr (lambda(x y)
                                            (cons
                                             (vector
                                              (string->number (col1 x))
                                              (string->number (col2 x))) y))
                                          '()  (car list-of-datasets))
                                   #:label (string-append "Dataset " (number->string count))
                                   #:color count) list-of-points) (+ count 1))))
   (plot (points-creator list-of-datasets col1 col2 '())
         #:title (string-append (col1 'name) " vs " (col2 'name))
         #:x-label (col1 'name)
         #:y-label (col2 'name))))




;;(define (plot-3D list-of-datasets col1 col2 col3)
;;(let ([count 0])
;;(define (3D-points-ceator list-of-datasets col1 col2 col3 list-of-points)
;; (if (null? list-of-datasets)
;;     list-of-points
;;      (begin
;;        (set! count (+ count 1))
;;        (3D-points-creator (cdr list-of-datasets) col1 col2 col3
;;                          (cons (points3d
;;                                (foldr (lambda(x y)
;;                                          (cons
;;                                          (list
;;                                           (string->number (col1 x))
;;                                           (string->number (col2 x))
;;                                           (string->number (col3 x))) y))
;;                                       '() (car list-of-datasets))
;;                                      #:sym 'dot #:size 20 #:color count) list-of-points)))))
;; (plot3d (3D-points-creator list-of-datasets col1 col2 col3 '()))))


;;(plot-3D list-of-datasets col1 col2 col3) -> plot?
;; list-of-datasets: list of datasets that are lists of lists
;; col1: colmun of the data set to plot on the x-axis
;; col2: colmun of the data set to plot on the y-axis
;; col3: colmun of the data set to plot on the z-axis
(define (plot-3D list-of-datasets col1 col2 col3)
  (define (3D-points-creator list-of-datasets col1 col2 col3 list-of-points count)
    (if (null? list-of-datasets)
         list-of-points
         (3D-points-creator (cdr list-of-datasets) col1 col2 col3
                            (cons (points3d
                                   (foldr (lambda(x y)
                                            (cons
                                             (list
                                              (string->number (col1 x))
                                              (string->number (col2 x))
                                              (string->number (col3 x))) y))
                                          '() (car list-of-datasets))
                                   #:label (string-append "Dataset " (number->string count))
                                   #:color count) list-of-points) (+ count 1))))
     (plot3d (3D-points-creator list-of-datasets col1 col2 col3 '() 1)
             #:title (string-append (col1 'name) " vs " (col2 'name) " vs " (col3 'name))
             #:x-label (col1 'name)
             #:y-label (col2 'name)
             #:z-label (col3 'name)))


;;(plot-statics data-set function param list-of-classes) -> plot?
;; data-set: al ist of list that contains database data
;; function: a procedure that was defined in data-filtering (average,min,max,...)
;; param: a procedure that is one of that data abstractions
;; list-of-classes: list of strings that are the class names to have a graph
;; usage (plot-statics (remove-last iris-raw) average sepal-width (list "Iris-virginica" "Iris-versicolor" "Iris-setosa"))
(define (plot-statics data-set function param list-of-classes)
  (define (histogram-creator dataset function param list-of-classes list-of-histograms count min)
    (if (null? list-of-classes)
         list-of-histograms
         (histogram-creator dataset function param (cdr list-of-classes)
                            (cons (discrete-histogram
                                   (list
                                    (vector
                                     (class (car
                                             (filter dataset param identity
                                                     (car list-of-classes))))
                                         (function dataset param (car list-of-classes))))
                                      #:x-min min #:color count) list-of-histograms)
         (+ count 1)(+ min 1))))
  (plot(histogram-creator data-set function param list-of-classes '() 1 0)
   #:title (string-append (param 'name) " Comparison")
   #:x-label "Class"
   #:y-label (param 'name)))