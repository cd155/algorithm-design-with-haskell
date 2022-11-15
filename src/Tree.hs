module Tree where

import Basics (Nat)
import Data.Map (Map, member, insert, empty)

-- A tree contains zero or more trees
data Tree a = Null1| Node1 a [Tree a] deriving Show

-- A binary tree contain max two trees
data BiTree a = Null | Node a (BiTree a) (BiTree a) deriving Show

-- A binary tree contain max two trees, and its parent
data BiTree' a =
    Null2 | Node2 a (BiTree' a) (BiTree' a) (BiTree' a) deriving Show

instance Ord a => Eq (BiTree a) where
  Null == Null = True
  Null == Node {} = False
  Node {} == Null = False
  Node x left1 right1 == Node y left2 right2 = (x == y) && (left1 == left2) && (right1 == right2)

{-
    What we defined here is a Direct Tree. (linked internally)

    Binary Search Tree: 
    all left trees (values) <= Node n < all right trees (values)

    Balanced Tree: 
    the height of left and right subtrees of every node differ <= 1

    Full tree: 
    every node other than the leaves has two children.

    Complete tree:
    every level, except the last, is completely filled
    and the last level is filled from left to right

    Perfect Trees: 
    all nodes have two children 
    and all leaves have the same level.
-}

-- Visit order: the left branch, the mid node, and the right branch
inOrderTraverse :: BiTree a -> [a]
inOrderTraverse Null = []
inOrderTraverse (Node n Null Null) = [n]
inOrderTraverse (Node n left Null) = inOrderTraverse left ++ [n]
inOrderTraverse (Node n Null right) = n: inOrderTraverse right
inOrderTraverse (Node n left right) =
    inOrderTraverse left ++ [n] ++ inOrderTraverse right

-- Visit order: the mid node, the left branch, and the right branch 
preOrderTraverse :: BiTree a -> [a]
preOrderTraverse Null = []
preOrderTraverse (Node n Null Null) = [n]
preOrderTraverse (Node n left Null) = n: preOrderTraverse left
preOrderTraverse (Node n Null right) = n: preOrderTraverse right
preOrderTraverse (Node n left right) =
    n: preOrderTraverse left ++ preOrderTraverse right

-- Visit order: the left branch, the right branch and the mid node, 
postOrderTraverse :: BiTree a -> [a]
postOrderTraverse Null = []
postOrderTraverse (Node n Null Null) = [n]
postOrderTraverse (Node n left Null) = postOrderTraverse left ++ [n]
postOrderTraverse (Node n Null right) = postOrderTraverse right ++ [n]
postOrderTraverse (Node n left right) =
    postOrderTraverse left ++ postOrderTraverse right ++ [n]

testTree1 =
    Node 10
        (Node 5
            (Node 3 Null Null) (Node 7 Null Null))
        (Node 20
            Null (Node 30 Null Null))

{-
    The (binary) heap data structure 
    is an array object that we can view as a nearly complete binary tree 

    Min Heaps: each node is smaller than its children
    Max Heaps: each node is greater than its children

    It would be better to implement a heap with an array.
    Using tree structure require more information share in the same level
-}

testHeap = [10, 5, 20, 3, 7, 30]

-- Append the element to the end of the list
insert' :: a -> [a] -> [a]
insert' x xs = xs ++ [x]

-- View the array as a heap structure
viewAsTree :: [a] -> BiTree a
viewAsTree = viewAsTreeHelper 0

viewAsTreeHelper :: Nat -> [a] -> BiTree a
viewAsTreeHelper _ [] = Null
viewAsTreeHelper track xs
    | track < size =
        Node (xs!!track) (viewAsTreeHelper leftTrack xs) (viewAsTreeHelper rightTrack xs)
    | otherwise = Null
    where size = length xs
          (leftTrack, rightTrack) = (2*track + 1, 2*track + 2)

-- Given an array, create a Max-Heap 
buildMaxHeap :: Ord a => [a] -> [a]
buildMaxHeap xs = buildMaxHeapHelper xs (length xs `div` 2)

buildMaxHeapHelper :: Ord a => [a] -> Nat -> [a]
buildMaxHeapHelper xs index
    | index < 0 = xs
    | otherwise = buildMaxHeapHelper (maxHeapify xs index) (index-1)

-- Given an Array and the index of the node, perform maxHeapify
maxHeapify :: Ord a => [a] -> Nat -> [a]
maxHeapify xs index
    | largestIndex /= index =
        -- swap index with largest, then repeat maxHeapify
        maxHeapify (swapTwoInList index largestIndex xs) largestIndex
    | otherwise = xs
    where largestIndex = maxInThree xs index leftTrack rightTrack
          (leftTrack, rightTrack) = (2*index + 1, 2*index + 2)

-- Find the largest index base on the value on three elements
maxInThree :: Ord a => [a] -> Nat -> Nat -> Nat -> Nat
maxInThree xs parent left right
    | left >= length xs = parent
    | left == (length xs - 1) =
        if xs!!parent >= xs!!left then parent else left
    | xs!!parent >= xs!!left && xs!!parent >= xs!!right = parent
    | xs!!left >= xs!!parent && xs!!left >= xs!!right = left
    | otherwise = right

-- Given two indexes and an list, swap the values in the list
swapTwoInList :: Nat -> Nat -> [a] -> [a]
swapTwoInList _ _ [] = []
swapTwoInList i j xs
    | i < j = firstHalf1 ++ [xs!!j] ++
        take (j-i-1) (tail secondHalf1) ++ [xs!!i] ++
        drop (j-i) (tail secondHalf1)
    | i > j = firstHalf2 ++ [xs!!i] ++
        take (i-j-1) (tail secondHalf2) ++ [xs!!j] ++
        drop (i-j) (tail secondHalf2)
    |otherwise = xs
    where (firstHalf1, secondHalf1) = splitAt i xs
          (firstHalf2, secondHalf2) = splitAt j xs

{-
    Heap Sort algorithm
    1. create a max-heap
    2. swap the first element(the largest) with the last element
    3. lock the last element, update the new heap, perform max-heap on new heap
    4. repeat step 2 until the list has one or less elements
-}
heapSort :: Ord a => [a] -> [a]
heapSort xs = heapSortHelper (buildMaxHeap xs)

heapSortHelper :: Ord a => [a] -> [a]
heapSortHelper [] = []
heapSortHelper [x] = [x]
heapSortHelper (x:xs) = heapSortHelper (maxHeapify swapArr 0) ++ [x]
    where swapArr = last xs : init xs

{-
    Depth-first search: starts at the root node
        explores as far as possible along each branch before backtracking.
        https://en.wikipedia.org/wiki/Depth-first_search

    Breadth-first search: 
        starts at the tree root and explores all nodes at the present depth 
        prior to moving on to the nodes at the next depth level.
        https://en.wikipedia.org/wiki/Breadth-first_search
-}

-- Depth-first search to find the path in a Tree
findPath :: Ord a => a -> BiTree a -> [a]
findPath t Null = []
findPath t (Node n Null Null) = if n == t then [n] else []
findPath t (Node n left Null)
    | t == n = [n]
    | otherwise = if null (findPath t left) then [] else n: findPath t left
findPath t (Node n Null right)
    | t == n = [n]
    | otherwise = if null (findPath t right) then [] else n: findPath t right
findPath t (Node n left right)
    | t == n = [n]
    | otherwise =
        if null (findPath t left) && null (findPath t right)
        then [] else n: findPath t left ++ findPath t right

{-
    Breadth-first way to find the path in a completed tree
    1. We can create a completed heap by using Breadth-first visit
    2. find whether the destination node exist in the array
    3. we can trace back the path, base on its index
-}
createPerfTree :: Ord a => BiTree a -> [Maybe a]
createPerfTree tree = createPerfTreeHelper' [tree]

{-
    Note: this only working for Complete Tree, a generic version requires
    expand Null to match the highest height. 
    Check listDepthHelper in LinkedList.hs
-}
createPerfTreeHelper :: [BiTree a] -> [Maybe a]
createPerfTreeHelper [] = []
createPerfTreeHelper [Null] = []
createPerfTreeHelper (Null: xs) = Nothing: createPerfTreeHelper xs
createPerfTreeHelper (Node n left right:xs) =
    Just n: createPerfTreeHelper (xs ++ [left, right])

-- Fill in a binary tree with Nothing to make it a nearly perfect tree
createPerfTreeHelper' :: Ord a => [BiTree a] -> [Maybe a]
createPerfTreeHelper' [] = []
createPerfTreeHelper' [Null] = []
createPerfTreeHelper' (Null: xs) =
    if null list then [] else Nothing: createPerfTreeHelper' (xs ++ [Null, Null])
        where list = [x | x <- xs, x /= Null]
createPerfTreeHelper' (Node n left right:xs) = Just n: createPerfTreeHelper' (xs ++ [left, right])

{-
    4.2 Given a sorted (increasing order) array with unique integer elements, 
    write an algo­rithm to create a binary search tree with minimal height.

    A complete tree will make a tree with the minimal height
-}
createBalTree :: Ord a => [a] -> [a]
createBalTree xs = createBalTreeHelper [xs]

{-
    Each time split the array into two separated arrays
    then, add new arrays to the queue.
    the queue will handle separated arrays one by one and remove empty arrays
-}
createBalTreeHelper :: Ord a => [[a]] -> [a]
createBalTreeHelper [] = []
createBalTreeHelper (x:xs)
    | null x = createBalTreeHelper xs -- a few empty list be added, need to remove them
    | otherwise = take 1 right ++ createBalTreeHelper (xs ++ [left, drop 1 right])
    where mid = length x `div` 2
          (left, right) = splitAt mid x

sortedArray = [1,3,5,7,10,11,20]

{-
    4.4
    Implement a function to check if a binary tree is balanced. 
    For the purposes of this question, 
    a balanced tree is defined to be a tree such that the heights 
    of the two subtrees of any node never differ by more than one.
-}
-- Check whether two heights are different than two
checkBalance :: BiTree a -> Bool
checkBalance root = if diff > 2 then False else True
    where pool = buildPool root 0
          maxDepth = foldl1 max pool
          minDepth = foldl1 min pool
          diff = maxDepth - minDepth

-- Create a collection that has all heights of leaves
buildPool :: BiTree a -> Nat -> [Nat]
buildPool Null depth = []
buildPool (Node n Null Null) depth = [depth]
buildPool (Node n left Null) depth = depth: buildPool left (depth+1)
buildPool (Node n Null right) depth = depth: buildPool right (depth+1)
buildPool (Node n left right) depth =
    buildPool left (depth+1) ++ buildPool right (depth+1)

-- test case
testTree2 =
    Node 1
        (Node 7
            (Node 2 Null Null)
            (Node 6
                (Node 5 Null Null)
                (Node 11 Null Null)))
        (Node 9
            Null
            (Node 9
                (Node 5 Null Null)
                Null))

{-
    4.5
    Implement a function to check if a binary tree is a 
    binary search tree: left trees (values) <= Node n < right trees
-}
-- Convert a tree to an array represent with in-order traverse
validateBST :: Ord a => BiTree a -> Bool
validateBST root = validateBSTHelper $ inOrderTraverse root

-- If it is a BST, the list represent is in ascending order
validateBSTHelper :: Ord a => [a] -> Bool
validateBSTHelper [] = True
validateBSTHelper [x] = True
validateBSTHelper (x1:x2:xs) = (x1 <= x2) && validateBSTHelper(x2:xs)

-- Balanced tree
testTree3 =
    Node 10
        (Node 5
            (Node 1 Null Null)
            (Node 9
                (Node 7 Null Null)
                Null))
        (Node 40
            (Node 20
                (Node 11 Null Null)
                (Node 30 Null Null))
            (Node 50 Null Null))

{-
    4.6
    Write an algorithm to find the in-order successor of a given node 
    in a binary search tree. 
    You may assume that each node has a link to its parent.

    in-order successor: the sequenced next node
-}

{-
    Solution1: using in-order traverse, then output is an in-order array.
    Assume all node are unique, then we find the next value of the node

    Solution2: Two condition, 
        the node has no right child: 
            find the first parent node which satisfy the condition 
        the node has the right child: 
            find the most leftest node in the right branch
-}

findSuccessor :: Ord a => BiTree a -> BiTree a
findSuccessor Null = error "Empty Tree"
findSuccessor (Node n _ Null) =
    error "find the first parent node which satisfy the condition"
findSuccessor (Node n _ right) =
    error "find the most leftest node in the right branch"

{-
    4.8
    Find the first common parent in a binary tree
-}

{-
    1. covert the ori from tree represent to an array represent
    2. find the index for both sub1 and sub2. In case of one of 
       them are not subtree of ori, return Null
    3. using map the check the most common parent they have

    xs = createPerfTree testTree3
-}
findFirstParent :: [Maybe a] -> Nat -> Nat -> Nat
findFirstParent xs sub1 sub2
    | (sub1 >= length xs) || (sub2 >= length xs) =
        error "Invalid sub trees"
    | otherwise = findFirstParentHelper sub1 sub2 empty

-- sub1 and sub2 are index of the array of binary tree represent, 
-- they are represent the root not of two subtree
findFirstParentHelper :: Nat -> Nat -> Map Nat Bool -> Nat
findFirstParentHelper sub1 sub2 dict
    | sub1 == sub2 = sub1
    | member sub1 dict = sub1
    | member sub2 dict = sub2
    | otherwise =
        findFirstParentHelper (par sub1) (par sub2) updateMap
    where par x
            | x == 0 = 0
            | odd x = (x-1) `div` 2
            | otherwise = (x-2) `div` 2
          updateMap = insert sub1 True (insert sub2 True dict)

{-
    4.9
    A binary search tree was created based on an array

    traversing the array from the left to the right, insert the node 
    immediately one by one base on the property of BST: for every node, 
    all left values <= parent value < all right values.

    ------ Example 1
    [5,4,2] and [5,2,4], will produce two different BSTs. 

    [5,4,2]: parent 5, 4 smaller than 5, put it on the left child of 5 , 
             2 is smaller 4, put it on the left child of 4
    Result => [5, 4, Null, 2] 

    [5,2,4]: parent 5, 2 smaller than 5, put it on the left child of 5 , 
             2 <= 4 < 5 , put it on the right child of 2 
    Result => [5, 2, Null, Null, 4] 
    ------

    ------ Example 2
    [10, 5, 20] and [10, 5, 20], will produce the same BST. 

    [10, 5, 20]: parent 10, 5 smaller than 10, put it on the left child of 10, 
                 20 is greater than 10, put it on the right child of 10
    Result => [10, 5, 20] 

    [10, 20, 5]: parent 10, 20 greater than 10, put it on the right child of 10, 
                 5 is smaller than 10, put it on the left child of 10
    Result => [10, 5, 20] 
    ------

    Given a binary search tree with distinct elements, print all 
    possible arrays that could have led to this tree.
-}

{-
    Useful Helper: find the all permutation of a set (can have the same value)
    test case: findAllPermu [] [1,2,3]
-}
findAllPermu :: [[a]] -> [a] -> [[a]]
findAllPermu accum [] = accum
findAllPermu [] (y:ys) = findAllPermu [[y]] ys
findAllPermu xs (y:ys) = findAllPermu (permutateHelper xs y) ys

-- Find all possible ways insert an element with multiple lists
permutateHelper :: [[a]] -> a -> [[a]]
permutateHelper [] add = []
permutateHelper (x:xs) add = permutateHelper xs add ++ permutate x add 0

-- Find all possible ways insert an element into a list
permutate :: [a] -> a -> Nat -> [[a]]
permutate xs add pos
    | pos > length xs = []
    | otherwise = (pre ++ [add] ++ app): permutate xs add (pos+1)
        where (pre, app) = splitAt pos xs

-- Produce all possible sequence to construct a balance search tree
-- Test case leftArr = [5, 2, 4], rightArr = [20, 30]
bstSequences :: Eq a => BiTree a -> [[a]]
bstSequences Null = []
bstSequences (Node n left right) = map (n:) (mergeRetainOrder leftArr rightArr)
    where leftArr = inOrderTraverse left
          rightArr = inOrderTraverse right

-- Add the (head ys) in to permutation, 
-- findAllPermu' start insert elements at the second index
mergeRetainOrder :: Eq a => [a] -> [a] -> [[a]]
mergeRetainOrder xs ys = findAllPermu' (permutate xs (head ys) 0) ys

-- Find the permutation with the constraint
findAllPermu' :: Eq a => [[a]] -> [a] -> [[a]]
findAllPermu' accum [] = accum
findAllPermu' [] (y:ys) = findAllPermu' [[y]] ys
findAllPermu' xs [y]= permutateHelper xs y
findAllPermu' xs [y1, y2]= findAllPermu' (permutateHelper' xs y1 y2) []
findAllPermu' xs (y1:y2:ys) = findAllPermu' (permutateHelper' xs y1 y2) (y2:ys)

-- similar with permutateHelper with a constraint add 'appear' after 'cons'
permutateHelper' :: Eq a => [[a]] -> a -> a-> [[a]]
permutateHelper' [] cond add = []
permutateHelper' (x:xs) cond add =
    permutateHelper' xs cond add ++ permutate' x cond add 0

-- similar with permutate with a constraint `add` appear after 'cons'
permutate' :: Eq a => [a] -> a -> a -> Nat -> [[a]]
permutate' xs cond add pos
    | pos > length xs = []
    | cond `elem` app = permutate' xs cond add (pos+1)
    | otherwise = (pre ++ [add] ++ app): permutate' xs cond add (pos+1)
        where (pre, app) = splitAt pos xs
