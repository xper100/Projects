# 1. 프로젝트 개요

혈중 납 중독이 영유아에게 활동항진증, 청각 또는 기억 손실, 학습장애, 신경계손상과 같이 다방면으로 건강에 악영향을 끼칠 수 있다. 

이를 방지하기 위해 Succimer 약물의 효과와 양에 따른 효과를 알아보기 위해 실험을 진행하였다. 실험 대상자는 12~36개월 된 영유아로 혈중 납 농도가 15μg/dL ~ 40μg/dL인 120명의 어린아이에게 각 3개의 다른 치료법을 진행하였다. 

40명씩 무작위로 선출하여 어떠한 치료를 하지 않은 **Placebo**, **적은 양의 Succimer**, **많은 양의 Succimer**를 투약하여 8주동안 2주마다 한번식 클리닉센터에 방문하여 총 5차례 진행하였다. 

# 2. 프로젝트 목적

프로젝트를 통해 답하고자하는 질문은 총 3가지이다.

1) Succimer의 투약량에 따른 혈중 납 배출 정도의 차이
2) 혈중 납 농도가 나이와 성별에 차이가 있는가?
3) Succimer의 효과가 나이와 성별에 영향이 있는가?

# 3. 데이터

| 변수명 | 설명 | 값
|---|---|---|
|Blood | 혈중 납 농도 | 0.5 ~ 48.3μg/dL
|trt | 3가지 다른 치료법 | * Placebo : 1 <br>* 적은 양의 Succimer : 2 <br> * 많은 양의 Succimer : 3
| Week | 클리닉센터에 방문한 주 | 0,2,4,6 and 8 (숫자형)
|Ind.age | 12~36개월 영유아 중 24개월을 기준으로 나눈 2개의 그룹 | * 24개월 이하 : 0 <br> * 24개월 초과 : 1
| Sex | 성별 | * Male : 0 <br> * Female : 1


# 4. 방법론

## 4.1 EDA

### 치료법에 따른 납 추출정도

![image](https://user-images.githubusercontent.com/53207478/134132749-333e5338-fea3-4900-8fee-1980506aa8e7.png)

- 진료 2주차까지는 세 그룹의 평균 혈중 납 농도의 차이가 없음
- Placebo 그룹의 혈중 납 농도는 26μg/dL 안밖으로 머무는 형태를 띔
- 투입량과는 상관없이 Succimer를 사용한 그룹은 2주차 이후부터 혈중 납 농도가 눈에띄게 낮아짐

### 성별에 따른 차이

![image](https://user-images.githubusercontent.com/53207478/134132788-edb6f5df-2a49-4a9a-bf9d-34fce0411560.png)

- 진료 첫날에는 여자아이들의 혈중 납 농도가 남자아이 보다 높음
- 하지만, 2주차 이후부터 여자아이들의 혈중 납 농도가 남자아이보다 낮은 상태로 유지


# 5. 모델링

### 모델들

![image](https://user-images.githubusercontent.com/53207478/134142813-78b20073-6c5d-4a2c-b257-029875838484.png)
![image](https://user-images.githubusercontent.com/53207478/134142418-faddfa6e-d9f9-4466-8f59-c35723371dea.png)
![image](https://user-images.githubusercontent.com/53207478/134142488-11e30bdb-1494-4147-b81c-b4c7801e730d.png)

### 혼합모델
![image](https://user-images.githubusercontent.com/53207478/134144816-a185759a-86d9-4888-8b50-cfdcd430b363.png)


# 6. 결론
