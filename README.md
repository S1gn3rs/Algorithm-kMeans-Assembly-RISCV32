# K-means Clustering in RISC-V32 Assembly

🛠️🕂⚙️ This project implements the k-means clustering algorithm in RISC-V assembly
for the Introduction to Computer Architecture subject. The goal is to identify
\( k \) clusters in a 2D space based on the relative proximity of
points. ⚙️🕂🛠️


## Project Description

Given an initial set of points in a 2D space, the program identifies \( k \)
clusters, taking into account the relative proximity of points in each cluster.
The iterative k-means algorithm is used, which is widely applied in various
fields such as computer vision, machine learning, cybersecurity intrusion
detection, and astronomy.


## Features

- Input: A set of 2D points, the number of clusters \( k \), and the maximum number of iterations \( l \).
- Output: The clusters and their centroids, displayed on a 2D matrix screen with distinct colors for each cluster.
- Intermediate steps: The clusters and centroids are updated and displayed iteratively.


## Inputs

- `points`: A vector of 2D points (each point consists of a pair of coordinates {x, y}).
- `n`: The number of points.
- `k`: The number of clusters to consider.
- `l`: The maximum number of iterations for the algorithm.

## Usage

The project is developed using the Ripes simulator and targets a 32-bit RISC-V
processor. The program performs all coordinate and distance calculations using
integer values, avoiding floating-point operations.


## Execution

1. Initialize centroids pseudo-randomly.
2. For each iteration:
   - Assign points to the nearest cluster based on Manhattan distance.
   - Recalculate the centroids for each cluster.
   - Display the updated clusters and centroids.
3. Terminate when the centroids no longer change or after \( l \) iterations.


## Project Organization

- `cleanScreen`: Clears all points from the screen.
- `printClusters`: Displays points on the screen with distinct colors for each cluster.
- `printCentroids`: Displays centroids on the screen.
- `calculateCentroids`: Calculates the centroids of clusters.
- `mainSingleCluster`: Executes steps for preliminary submission with \( k = 1 \).
- `mainKMeans`: Executes the k-means algorithm for the final submission.

## Development

This project was developed in a group of two students, with a preliminary
submission demonstrating initial functionality and a final submission for the
complete implementation.

Enjoy ;)
