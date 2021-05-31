---
layout: post
title: "루씬 색인 예제"
author: "이준명"
tags: Lucene
---
### IndexWriter
> lucene에서 _**색인을 담당하는 클래스**_이다. 해당 클래스를 이용하여 문서의 내용을 색인한다.
> (해당 클래스에서는 검색된 내용을 확인은 불가능하다고 적혀있다. 나중에 검색을 담당하는 클래스에 의해서 확인이 가능해 보인다.) 
> 
> 파일의 형태로 저장되며 lucene의 검색저장 자료구조인 `segments`로 저장된다. 해당 자료구조는 후에 자세히 다루고자 한다.
> 책에 적혀있는 lucene **version 3.0** 코드를 _**version 8.6.2**_ 기준으로 재 변경 하였다.

#### 생성자 메소드
```java
    private IndexWriter indexWriter;
    public Indexer(String indexDir) throws IOException {
        // 변경 코드 open(new File) -> open(Path)
        Directory dir = FSDirectory.open(Paths.get(indexDir));
        indexWriter = new IndexWriter(dir, new IndexWriterConfig(new StandardAnalyzer()));
    }

    public void close() throws IOException{
        indexWriter.close();
    }
```
IndexerWriter를 초기화 해주고 초기화 설정은 StandardAnalyzer이다.


#### Directory ( 더 여러가지가 있는것으로 보이나 대표적인 종류 2가지만 나열 )
* RAMDirectory : 메인메모리를 색인 장소로 사용(deprecated)
* FSDirectory : 디스크를 색인 장소로 사용(가장 많이 사용)

#### 색인 프로세스 메소드
```java
    public int index(String dataDir, FileFilter filter) throws Exception {
        File[] files = new File(dataDir).listFiles();
        for(File file : files){
            if(!file.isDirectory() && !file.isHidden() && file.exists() && file.canRead() && (filter == null || filter.accept(file))){
                indexFile(file);
            }
        }
        //변경 코드 indexerWriter.numDocs() -> indexerWriter.getDocStats().numDocs
        return indexWriter.getDocStats().numDocs;
    }
```
지정된 폴더의 파일 리스트를 loop하며 색인한다. 반환값은 색인된 파일의 개수 이다.

#### 필드 설정 및 색인 메소드 
```java
    public void indexFile(File file) throws Exception {
        System.out.println("Indexing " + file.getCanonicalPath());
        Document doc = getDocument(file);
        indexWriter.addDocument(doc);
    }
    public Document getDocument(File file) throws Exception {
        Document doc = new Document();
        //변경코드 new Field() -> new TextField()
        //변경코드 Field.Index.NOT_ANALYZED -> 삭제됨
		doc.add(new TextField("contentsFile", new FileReader(file)));
        doc.add(new StringField("contentsString", FileUtils.readFileToString(file, StandardCharsets.UTF_8), Field.Store.YES));
        doc.add(new StringField("filename", file.getName(), Field.Store.YES));

        return doc;
    }
```

> _**new TextField("field", new FileReader(new File("filename))**_ 으로 사용시 Store는 Un-Store이다.
즉, 해당 필드로 색인시, 검색필드의 역할은 가능해도 노출필드의 역할은 수행할 수 없다.!
노출필드로 만들고 싶을 경우, new StringField("field", "file contents", Store) 의 형태가 되어야 한다.

Document를 생성하여 파일의 내용, 파일의 제목을 가지는 색인 문서 설정을 한뒤에, IndexerWriter클래스에 add하여 색인한다.
#### Field.Store([참조 링크](http://theeye.pe.kr/archives/287))
* **Store.YES** : 인덱스를 할 값 모두를 인덱스에 저장한다. 검색결과등에서 꼭 보여야 하는 내용이라면 사용한다.
* **Store.NO** : 값을 저장하지 않는다. Index 옵션과 혼합하여, 검색은 되데, 원본글이 필요없을 경우 사용될수 있다.
* **Store.COMPRESS** : 값을 압축하여 저장한다. 저장할 글의 내용이 크거나, 2진 바이너리 파일등에 사용한다.
#### Field([참조 링크](https://tourspace.tistory.com/239))
* **StringField** : index에는 포함하지만 tokenized는 하지 않는다. string 전체가 하나의 token(ES에서 keyword인듯 하다)
* **TextField** : index에 포함되며 tokenized 한다. term vector는 생성하지 않는다. (ES에서 text인듯 하다)
* **StoredField** : value가 저장되기 때문에 IndexSearcher.doc(int)와 IndexReader.document()로 field와 값을 return 할수 있다.
주로 숫자를 입력할 때 사용한다.(Text와 String은 따로 필드가 존재해서)
단, StoredField의 경우, range search나 sort를 할 수 없다. 해당 기능을 수행하려면 xxxDocValuedField를 함께 사용해야한다.

#### FileFilter Override
```java
    private static class TextFilesFilter implements FileFilter{
        @Override
        public boolean accept(File file) {
            return file.getName().toLowerCase().endsWith(".txt");
        }
    }
```
파일의 확장자가 txt인 파일만 색인 대상으로 설정한다.

#### 메인 메소드
``` java
    public static void main(String[] args) throws Exception{
        String indexDir = "/data/test/index_data";       // 해당 디렉토리에 색인 파일 생성
        String dataDir = "/data/test";                   // 해당 디렉토리의 파일을 대상으로 색인 지정

        Indexer indexer = new Indexer(indexDir);
        int count = 0;
        try{
            count = indexer.index(dataDir, new TextFilesFilter());
        }catch (Exception e){
            e.printStackTrace();
        }finally {
            indexer.close();
        }
        System.out.println("Indexing num " + count);
    }
```
TextFileFilter로 확장자가 txt인 파일만 색인하는 프로세스를 실행하되 반환값으로 색인된 문서의 개수값을 가져온다.

#### 결과 출력문
```
Task :Indexer.main()
Indexing /System/Volumes/Data/data/test/test1.txt
Indexing /System/Volumes/Data/data/test/test2.txt
Indexing num 2
```

#### 결과 생성 파일
![](https://images.velog.io/images/mertyn88/post/b9574080-7094-492b-a252-ce5919eae664/image.png)
