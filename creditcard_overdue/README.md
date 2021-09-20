# 신용카드 사용자 연체 예측

신용카드 사용자의 고객데이터를 통해 연체여부 예측하기

# 무엇이 알고싶은가?

**궁금증:**

**은행은 고객의 어떤 특징을 중요하게 보고 판단할까?**
- 학력 및 직업군이 미치는 영향
- 자가, 자차 소유여부가 미치는 영향
- 가족 구성단위가 미치는 영향
- 직업 경력이 미치는 영향

**선택이유:** 

- 사회초년생의 입장에서 신용등급과 관련된 특성이 알고싶어서



# 데이터
데이콘에서 개최한 공모전의 데이터를 활용하였습니다.

[신용카드 사용자 연체 예측 AI 경진대회](https://dacon.io/competitions/official/235713/overview/description)

19개의 특성과 타겟값(신용도)

훈련용 데이터 (Train): 26,475개 (3.3MB)

테스트용 데이터 (Test): 10,000개 (1.2MB)

## 데이터 설명

**특성** | **설명** | **분류**
--- | --- | ---
gender | 성별 | M or F
car | 차량 소유 여부 | Y or N
reality | 부동산 소유 여부 | Y or N
child_num | 자녀 수 | 
income_total | 연간 소득 | 
income_type | 소득 분류 | 'Commercial associate', 'Working', 'State servant', 'Pensioner', 'Student'
edu_type | 교육 수준 | 'Higher education' ,'Secondary / secondary special', <br> 'Incomplete higher', 'Lower secondary', 'Academic degree'
family_type | 결혼 여부 | 'Married', 'Civil marriage', 'Separated', 'Single / not married', 'Widow'
house_type | 생활 방식 | 'Municipal apartment', 'House / apartment', 'With parents', <br> 'Co-op apartment', 'Rented apartment', 'Office apartment'
DAYS_BIRTH | 출생일 | 데이터 수집 당시 (0)부터 역으로 셈 <br> 즉, -1은 데이터 수집일 하루 전에 태어났음을 의미
DAYS_EMPLOYED | 업무 시작일 | 데이터 수집 당시 (0)부터 역으로 셈 <br> 즉, -1은 데이터 수집일 하루 전부터 일을 시작함을 의미 <br> (단, 양수 값은 고용되지 않은 상태를 의미함)
FLAG_MOBIL | 핸드폰 소유 여부 | 
work_phone | 업무용 전화 소유 여부 |
phone | 전화 소유 여부 |
email | 이메일 소유 여부 |
occyp_type | 직업 유형 |											
family_size | 가족 규모 |
begin_month | 신용카드 발급 월 | 데이터 수집 당시 (0)부터 역으로 셈 <br> 즉, -1은 데이터 수집일 한 달 전에 신용카드를 발급함을 의미
**credit** | **사용자의 신용카드 대금 연체를 기준으로 한 신용도 (타겟값)** | 낮을 수록 높은 신용의 신용카드 사용자를 의미함
    
    
출처: [데이콘 - 데이터 설명](https://www.dacon.io/competitions/official/235713/talkboard/402821/)

## EDA

![image](https://user-images.githubusercontent.com/53207478/134003107-df9622c8-abb8-451e-9835-b53935abc37e.png)

![image](https://user-images.githubusercontent.com/53207478/134002860-c93cc45f-7e97-444f-b6ef-e5668fb3bf76.png)

![image](https://user-images.githubusercontent.com/53207478/134002968-ab7b4e19-6555-49a9-86da-a71763950d78.png)

![image](https://user-images.githubusercontent.com/53207478/134003011-787aa157-4420-443e-84da-f47c1f8ca756.png)

![image](https://user-images.githubusercontent.com/53207478/134003052-8a29cb5a-ea18-4bd7-853f-e48b0c58ff94.png)


## 데이터가공



**특성** | **설명** | **특징**
--- | --- | ---
begin_month / begin_year | 신용카드 가입 후 기간 (월/년)  | 
Month_birth / Wweeks_birth / Year_birth |  생일 (월/주/년)  | 
Month_employed/ Weeks_employed /Year_employed | 고용 후 기간 (월/주/년)  | 
before_employed_months / before_employed_weeks | 고용 전 기간 (월/주)  | 
diff_employed_begin_year / diff_employed_begin_month | 고용 후 발급날짜와의 차이 (년/월) | 
income_family_ratio | 부양가족 당 수입 비율 | 총 수입(total_income) / 가족규모(family_size)
Unique_ID | 고유번호 | "나이_자녀수_연간수입_차소유_자녀수_학벌_가족규모_성별_총수입_결혼여부_주거형태_나이_고용 이후 날짜"




# 모델링

**Categorical데이터 인코딩 방식**: 타겟 인코딩

**하이퍼파라미터 튜닝 방식**: 랜덤서치 (Randomized Search CV)

**성능지표**: ROC-AUC Curve


|모델 | LogLoss | Train | Vaidation
|:---:|:---:|:---:|:---:|
Rogistic Regression| 0.7289 | 0.7691 | 0.7727
Random Forest| 0.6206| 0.8090 |0.7337
XGBoost| 0.5456 | 0.8234 | 0.7899
LightGBM| 0.5328 | 0.8287 | 0.7903
Catboost| 0.5460| 0.8115 | 0.7915
**Stacking Ensemble**| **0.5197**| **0.8360** | **0.8105**


**최종모델: Stacking Ensemble**

**이유**: 손실함수가 가장 낮으며 훈련용과 검증용 데이터에서 ROC-AUC Curve 수치가 가장 높다.

# 결론


## 어려웠던 점

- 타겟값인 Credit이 3개의 클래스로 나뉘어져 있으며 불균형하게 분포되어 예측값이 한쪽으로 치우치즌 경향이 있었다.

## 추가적으로 해볼만한 것들...

- 다양한 특성공학 방식을 통해 성능실험을 수행하여 시간적으로 많이 부족하였다. 이를 극복하기 위해서는, 하이퍼파라미터 튜닝없이 기본적으로 돌린 후 튜닝을 진행해야겠다.
- 스태킹앙상블 이외의 보팅과 블랜딩 등 다른 앙상블 모델을 통해 실험해봐야겠다.




