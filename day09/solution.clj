(require '[clojure.string :as str])

(defn parse-line [line]
  (map parse-long (str/split line #",")))

(defn area-between [[x0 y0] [x1 y1]]
  (let [dx (abs (- x0 x1))
        dy (abs (- y0 y1))]
    (* (+ 1 dx) (+ 1 dy))))

(defn solve-part-1 [input]
  (let [points (map parse-line (str/split-lines input))]
    (apply max (for [a points b points] (area-between a b)))))

(-> (or (first *command-line-args*) *in*)
    slurp
    solve-part-1
    println)
