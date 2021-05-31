---
layout: post
title: "루씬 검색 예제"
author: "이준명"
tags: Lucene
---
#### IndexSearcher
> lucene에서 검색을 담당하는 클래스이다. 해당 클래스를 이용하여 문서의 색인을 `검색`한다. 검색이후 검색된 결과를 가지고 있는 객체를
통해서 Iterator하여 출력한다.

#### IndexReader
> 색인된 파일을 읽는 클래스이다. 색인된 파일이 있는 위치를 지정하여 검색대상 위치를 지정할 수 있다.

다음과 같은 형태로 String형태의 index path를 받아서 IndexerSearcher를 구성한다.
```java
Directory indexDir = FSDirectory.open(Paths.get(indexPath));
IndexReader indexReader = DirectoryReader.open(indexDir);
IndexSearcher indexSearcher = new IndexSearcher(indexReader);
```

#### QueryParser
> 검색질의식을 만들기 위한 클래스이다. 설정을 넣고 parse하여 lucene에게 어떠한 검색어에 매칭되는 결과를 얻고 싶은지 결정한다.

다음과 같은 형태로 질의식을 요청한다.
```java
QueryParser queryParser = new QueryParser("contentsFile", new StandardAnalyzer());
Query query = queryParser.parse(input);
```
QueryParser에 의해 만들어진 질의식은 다음과 같다.
> contentsFile:개행이
 
 1. `contentsFile`필드를 검색대상으로 지정한다.
 2. `contentsFile`필드에 `개행이`라는 문구가 포함된 문서를 검색한다.
  

#### TopDocs
> 검색을 수행하고 결과를 얻기 위한 클래스이다. `parameter`로 parse된 질의식과 노출 건수를 설정한다.

```java
 TopDocs hits = indexSearcher.search(query, 10);
 // 결과 건수
 System.out.println(hits.totalHits);
 // 검색 결과 노출
for(ScoreDoc scoreDoc : hits.scoreDocs){
    Document doc = indexSearcher.doc(scoreDoc.doc);
    System.out.println(doc.get("contentsFile"));
    System.out.println(doc.get("contentsString"));
    System.out.println(doc.get("filename"));
    System.out.println("------------");
}
```
해당 결과에서 contentsFile의 값은 `null`이다. _**검색을 contetnsFile로 하였는데 노출이 null이라니!**_ 
이유는 색인에서 설정한 값에 의해서 인데 contentsFile을 색인시 , TextField("field", FileReader)의 형태로 색인을 하였기 때문이다.
해당 방식은 _**un-store**_이며 검색만 가능하고 노출을 할 수 없는 옵션이다.


#### 실행 결과
```
1 hits
Parse Query >> contentsFile:개행이
null
이 파일은 두번째 파일 입니다.
개행이 포함되어있습니다.
```
