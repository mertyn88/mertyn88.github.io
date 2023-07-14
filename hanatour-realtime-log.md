---
layout: project-layout
---
# 실시간 로그 연동

| 프로젝트명 | 실시간 클릭로그 수집프로젝트 |
| --- | --- |
| 프로젝트기간 | 2022.03 ~ 2023.05 (3개월) |
| 참여인력 | 개발자 1 |
| 사용한 기술스택 | Java, Elasticsearch, Spring Boot, Ingest-pipeline, Painless script |

## 프로젝트 소개

---

하나투어의 로그 색인은 `배치로 설정된 스케쥴`에 의해 로그 클러스터에 색인이 된다. 앱이나 사이트를 방문한 사용자에게 로그 데이터를 기반으로 `추천의 영역이 필요`해지면서 기능이 개발이 되었지만 배치의 반영 시간은 `1시간`이였다.  

사용자에게 클릭이 일어날 때마다 추천 상품을 노출해주기 위해, `클릭한 상품에 대해서만큼은 준실시간의 반영`이 필요해 졌다.

## 전체 시스템 구성

---

![Untitled](./projects/images/%EC%8B%A4%EC%8B%9C%EA%B0%84_%EB%A1%9C%EA%B7%B8_%EC%97%B0%EB%8F%99_1.png)

### AS-IS

***Kafka → HIVE → Batch → Index***

HIVE에 데이터가 유입된 이후 스케쥴에 의해서 배치 프로세스가 동작하게 된다. 이후 `Service` 의 이름을 기반으로 전처리, 후처리를 하고 색인한다.

### TO-BE

***Kafka → Daemon → Ingest → Index***

Consumer Daemon에 의해 실시간으로 데이터를 가져온 이후, `Service` 의 이름을 기반으로 색인되어져야 하는 인덱스와 Pipeline이름을 설정, `Elasticsearch Ingest`에 의해 `실시간 후처리` 이후 색인 한다.

## 프로젝트에 기여한 내용

---

### Ingest pipeline 구성

파이프라인을 Plugin 형태로 만들어 설치형태로 가려고 했다. 하지만 추가적인 개발이 필요한 경우, 재배포의 단계가 필요했다. 이때, 재배포의 단계를 거치지 않기 위해 `Painless script`로 개발을 진행했다.

[파이프라인 Plugin 예제 작성 주소 (Github)](https://github.com/mertyn88/ingest-plugin-sample)

```json
// POST _ingest/pipeline/_simulate
{
  "pipeline": {
    "processors": [
      {
        "script": {
          "lang": "painless",
          "source": """
            // script code
          """
        }
      }
    ]
  },
  "docs": [
    {
      "_source": {
        // test data
      }
    }
  ]
}
```

### Consumer daemon project 개발

`Kafka-connect sink connect plugin`을 설치해서 바로 Elasticsearch로 색인을 하고자 하였다. 하지만 Kafka topic에 담기는 데이터는 N개의 서비스를 가지고 있으며, 그에 따른 `“eventData”`라는 필드는 서비스별로 내용이 다르다. 

Consume되는 데이터의 Service를 파싱하여 적절한 인덱스로 보내주는 기능이 필요했으므로 Daemon 프로젝트를 개발했다. (Srping boot `@KafkaListener` )

![Untitled](./projects/images/%EC%8B%A4%EC%8B%9C%EA%B0%84_%EB%A1%9C%EA%B7%B8_%EC%97%B0%EB%8F%99_2.png)

### 파이프라인 예외처리

Pipeline 처리시, 예외가 발생하는 데이터는 정상데이터로 판단하지 않는다. 

> 잘못된 날짜 형식, 범위를 벗어나는 금액 등
> 

이때, 잘못 필드 구성 데이터에 대해서는 ingest.error 필드를 만들어 어떠한 단계에서 예외가 발생했는지 저장하여 색인하도록 한다. 

> 파이프라인에서는 대상이 되는 모든 데이터를 색인처리 한다. 단, 사용할 때는 ingest.error 필드가 없는 데이터라는 검색 조건을 걸어서 수집한다.
> 

![Untitled](./projects/images/%EC%8B%A4%EC%8B%9C%EA%B0%84_%EB%A1%9C%EA%B7%B8_%EC%97%B0%EB%8F%99_3.png)

## 프로젝트 성과

---

### 준실시간 클릭 로그 색인

100개의 데이터 큐가 쌓이거나, 3초가 되면 Consumer daemon에서 파이프라인으로 데이터를 전송하게 된다. 
즉, `최대 3초의 준실시간 클릭 로그 색인`이 가능해졌다.

여행 상품을 클릭한 사용자는 실시간으로 변경되는 추천 상품 리스트를 보게 될 것이고, 이는 사용자를 `하나투어 앱을 좀더 탐색하게 만드는 계기`가 되었다.

### 예외 데이터 0건

클릭 로그 배치가 수행될 때에는, 테스트로 인한 잘못된 데이터가 들어오게 되고, 해당 데이터를 정제할때 배치 전체의 예외가 발생하게 된다. 배치는 `실패`하게 되고 실패 데이터가 들어있는 `전체 Queue부터 이후의 데이터는 색인이 이루어 지지 않는다` 

잘못된 데이터는 정제 단계에서 `ingest.error`로 거르기 때문에 배치에서 처럼 잘못된 데이터를 정제하여 예외가 발생하는 경우가 없어졌다.

## 트러블 슈팅

---

### Elasticsearch Index 생성시 Pipeline 설정 ( Kafka-connect )

Kafka connect로 초기 구성시, Index 설정에 대상 파이프 라인을 설정하여 처리를 하고자 했다. 하지만 Index에 Ingest pipeline을 설정함과 동시에 `색인에 제약조건`이 걸리는듯 하다. 단순히 인덱스를 생성하고 색인작업을 할 경우, 모든 데이터를 수용하는데 Ingest pipeline을 인덱스에 설정을 해버리면, 색인 실패 이슈가 생겨날 수 있다.

서비스 별로 `“eventData”`라는 필드에는 각각 다른 필드들이 들어가 있는데, 이때 pipeline에 해당하지 않는 필드값이 와서 예외가 발생하는듯 하다.

**[이슈케이스 시나리오]**

1. 파이프라인으로 A, B, C 필드를 정의한다.
2. A, B, C 필드로 색인이 진행되다가 새로이 삽입되는 API에서 `A, C 필드만 내용을 전송`한다.
3. B 필드가 존재하지 않는 에러와 함께 색인이 진행되질 않으며, 이후 `정상적인 A, B, C 필드로 보내는 데이터도 전송이 되질 않는다`.

> 초기 카프카 커넥트에서 ingest 관련 예외가 발생한다. ( B필드가 정의되지 않아서 색인이 실패한다는 … ) 이후 정상적인 rest 요청에 로그는 성공처럼 보여지는데 실제로 색인된 데이터는 존재하지 않는다.
> 

### Painless 미숙

Painless 언어로 모든 처리를 구현하고자 한다. 이때 ES의 버전에 따라서도 동작이 되는 코드가 있거나, 동작을 하지 않는 코드가 있다. 실시간 배포를 위해 Painless로 진행하였지만 정말 많은 구글링을 시도 하였다. 

> 해당 부분은 트러블 슈팅이라기 보다는 이 부분으로 인하여 많은 시간을 소비하였으므로 추가 한다.
> 

## 아쉬운 점

### 색인되어지는 필드의 순서

Ingest pipeline으로 후처리를 하게 되면 `값들의 순서는 보장될 수 없다`. Input으로 들어오는 데이터는 Json형태이고, Script를 통해 `Map형태(HashMap)`로 변경하게 된다. 전처리 작업을 Map 객체를 통해 작업하게 되고, **이 때 해당 객체값이 그대로 색인이되는 문서가 된다**. 그러므로 순서가 틀어지게 된다. 기능적인 문제는 없지만, 보여지는 결과 값은 순서가 달라졌으므로 가독성이 많이 떨어졌다.

### 플러그인 배포

ES에 플러그인 형태로 배포하는 예제는 만들어봤지만, 실제 운영에 적용을 못해본것이 아쉽다. 또한 Java로 구현할테니 파이프라인에서보다는 좀더 나은 형태의 모습이 되지 않았을까 하는 아쉬움이 있다.

## 추가 참조

Consumer와 Ingest pipeline간의 부하를 테스트 해보았다. Consumer는 얼마나 문제없이 데이터를 가져올 것이며, Pipeline은 얼마나 문제없이 문서 색인이 될 것인지에 대한 부분이다. 실제 운영 서버에서는 테스트 해 볼 수 없어 도커 구성을 하고 진행하였다.

[Log consumer docker 부하 테스트](https://velog.io/@mertyn88/Elasticearch-Ingest-%EC%83%89%EC%9D%B8-%EB%B6%80%ED%95%98-%ED%85%8C%EC%8A%A4%ED%8A%B8)