(ns util
  (:import (org.apache.commons.io FileUtils)
	   (java.io File)))

(defn guard [pred msg]
  (if (not pred)
    (throw (RuntimeException. msg))))

(defn only [xs]
  (guard (= 1 (count xs))
	 "xs must have count 1")
  (first xs))

(defn system [command]
  nil)

(defn force-mkdir [directory-path]
  (FileUtils/forceMkdir (File. directory-path)))

(defmacro mkdir [& args]
  (let [is-option (fn [arg]
		    (or 
		     (= '-p arg)
		     (= '-f arg)))
	options (filter is-option args)
	arguments (remove is-option args)]
    (cond 
     (some #(= % '-p) options) `(force-mkdir ~(only arguments)))))

(defn exists? [path]
  (.. (File. path) (exists)))

(defn force-remove-recursive [path]
  (FileUtils/deleteDirectory (File. path)))

(defmacro rm [& args]
  (let [is-option (fn [arg]
		    (or 
		     (= '-rf arg)
		     (= '-r arg)
		     (= '-f arg)))
	options (filter is-option args)
	arguments (remove is-option args)]
    (cond 
     (some #(= % '-rf) options) `(force-remove-recursive ~(only arguments)))))
