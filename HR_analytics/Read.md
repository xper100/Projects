# 데이터직군으로 전직을 위한 중요한 요소

데이터사이언티스트로 전향하기 위해 필요한 조건을 HR 데이터로 살펴보기


# 무엇을 알고 싶은가?
**궁금증:**

**데이터직군의 HR은 어떤요소를 많이 볼까?**
- 데이터 분석업무 경험의 영향
- 학력 영향
- 데이터분석 관련 교육수료 영향

**선택이유:** 

- 코드스테이츠에서 AI부트캠프를 진행하여 전직을 희망하는 동기생들과 비슷한 상황
- 코드스테이츠 DS부트캠프를 같이 진행하는 동기생들의 90%이상이 비전공자 출신
- 수업 및 학습을 진행하며 가지고 있는 공통된 질문: "비전공자인데 정말 데이터직군으로 전향할 수 있을까?"


# 데이터
캐글의 데이터사이언티스트의 직업전환과 관련된 HR 데이터를 기반으로 프로젝트를 진행했습니다.

[Kaggle - HR Analytics: Job Change of Data Scientists](https://www.kaggle.com/arashnic/hr-analytics-job-change-of-data-scientists)

훈련용 데이터 (Train): 26,500개 (3.3MB)

테스트용 데이터 (Test): 10,000개 (1.2MB)

## 데이터가공

![image](https://user-images.githubusercontent.com/53207478/133868002-8319cde3-94e4-44ef-9fd4-7c54e683f6fb.png)
![image](https://user-images.githubusercontent.com/53207478/133867932-8fcb710f-fa87-4671-a7a9-415eee39f7b7.png)


# 모델링

**Categorical데이터 인코딩 방식**: 타겟 인코딩

**하이퍼파라미터 튜닝 방식**: 랜덤서치 (Randomized Search CV)

**성능지표**: ROC-AUC Curve


|모델 | Best Score | Train | Vaidation
|:---:|:---:|:---:|:---:|
Rogistic Regression| 0 | 0.6873 | 0.6816
Random Forest| 0.8012| **0.7437**|0.6816
XGBoost| 0.8009| 0.7430|0.7290
LightGBM| **0.8019**| 0.7353|**0.7320**

**최종모델: LightGBM**

**이유**: 훈련용과 검증용 데이터에서 ROC-AUC Curve의 차이가 없으며, 검증데이터 관련 성능이 가장 높음

# 결과

![image](https://user-images.githubusercontent.com/53207478/133868034-0f30b5e1-81f1-4a5b-81fd-4fea380f1535.png)
* 속한 도시의 산업발전도가 전직을 고려하게 만드는 주요한 요인이다

* 현재 직장의 형태(Company_type)와 크기(Company Size)가 그 다음으로 큰 영향이 있다.

* 관련경험(Relevent_experience) 보다는 **커리어 경험(experience)** 

* Data Science직종은 전공과는 거의 무관하다. 즉, 비전공자도 할 수 있다.

* 트레이닝 시간은 상대적으로 영향도가 낮다. 

* 이직경험(experience of turnover)과 성별(Gender)은 거의 영향이 없다.

**따라서, 관련 경험도 중요하지만 현재 가지고 있는 커리어의 경럼과 그에 파생되는 경험적인 지식을 활용하여 꾸준히 훈련하자! 그리하면 입사가능성이 높아진다!**



