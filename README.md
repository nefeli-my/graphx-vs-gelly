Code used for Analysis and Design of Information Systems project dedicated on the comparison of Apache Spark's GraphX and Apache Flink's Gelly.
For the benchmarks, we used GraphX's and Gelly's already bundled algorithms:
- GraphX
  - [Connected Components](https://github.com/apache/spark/blob/master/graphx/src/main/scala/org/apache/spark/graphx/lib/ConnectedComponents.scala)

  - [Page Rank](https://github.com/apache/spark/blob/master/graphx/src/main/scala/org/apache/spark/graphx/lib/PageRank.scala)

- Flink
  - [Connected Components](https://github.com/apache/flink/blob/master/flink-examples/flink-examples-batch/src/main/scala/org/apache/flink/examples/scala/graph/ConnectedComponents.scala)
  - [Page Rank](https://github.com/apache/flink/blob/master/flink-examples/flink-examples-batch/src/main/scala/org/apache/flink/examples/scala/graph/PageRankBasic.scala)

