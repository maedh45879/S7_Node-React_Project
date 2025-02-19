CREATE OR REPLACE TRIGGER trg_loans_after_insert
AFTER INSERT ON loans
FOR EACH ROW
DECLARE
    v_current_balance NUMBER;
BEGIN
    -- Récupérer le solde de crédit actuel du client
    SELECT TO_NUMBER(Current_Credit_Balance) INTO v_current_balance
    FROM credit_history
    WHERE customer_id = :NEW.customer_id;

    -- Mettre à jour le solde de crédit avec le montant du nouveau prêt
    UPDATE credit_history
    SET Current_Credit_Balance = TO_CHAR(v_current_balance + TO_NUMBER(:NEW.current_loan_amount))
    WHERE customer_id = :NEW.customer_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Aucun historique de crédit trouvé pour ce client
        DBMS_OUTPUT.PUT_LINE('Aucun historique de crédit trouvé pour le client ' || :NEW.customer_id);
END;
/


CREATE OR REPLACE TRIGGER trg_credit_history_after_update
AFTER UPDATE ON credit_history
FOR EACH ROW
BEGIN
    -- Détecter si le nombre de problèmes de crédit est passé de 0 à une valeur positive
    IF TO_NUMBER(:NEW.Number_of_Credit_Problems) > 0 
       AND TO_NUMBER(:OLD.Number_of_Credit_Problems) = 0 THEN
        DBMS_OUTPUT.PUT_LINE('ALERTE : Le client ' || :NEW.customer_id || 
                             ' a maintenant des problèmes de crédit !');
    END IF;
END;
/


CREATE OR REPLACE TRIGGER trg_customers_credit_score_check
BEFORE UPDATE ON customers
FOR EACH ROW
BEGIN
    -- Vérifier si le Credit_Score est inférieur à 600
    IF :NEW.Credit_Score IS NOT NULL 
       AND TO_NUMBER(:NEW.Credit_Score) < 600 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Mise à jour refusée : le Credit_Score ne peut pas passer sous 600.');
    END IF;
END;
/


CREATE OR REPLACE TRIGGER trg_customers_default_credit_score
BEFORE INSERT ON customers
FOR EACH ROW
BEGIN
    -- Attribuer un score de crédit par défaut si aucun n'est fourni
    IF :NEW.Credit_Score IS NULL THEN
        :NEW.Credit_Score := '700';
        DBMS_OUTPUT.PUT_LINE('Aucun score crédit fourni. Score par défaut (700) attribué au client ' || :NEW.customer_id);
    END IF;
END;
/


CREATE OR REPLACE TRIGGER trg_financial_obligations_check_debt
BEFORE INSERT OR UPDATE ON Financial_Obligations
FOR EACH ROW
DECLARE
    v_annual_income NUMBER;
    v_max_monthly_debt NUMBER;
BEGIN
    -- Récupérer le revenu annuel du client
    SELECT TO_NUMBER(Annual_Income) INTO v_annual_income
    FROM customers
    WHERE customer_id = :NEW.customer_id;

    -- Vérifier que le revenu annuel est défini et non nul
    IF v_annual_income IS NULL OR v_annual_income = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Impossible de vérifier la dette : Annual_Income non défini pour le client ' || :NEW.customer_id);
        RETURN;
    END IF;

    -- Calculer la dette mensuelle maximale autorisée
    v_max_monthly_debt := (v_annual_income / 12) * 0.5;

    -- Vérifier si la dette mensuelle dépasse le seuil maximal
    IF TO_NUMBER(:NEW.Monthly_Debt) > v_max_monthly_debt THEN
        RAISE_APPLICATION_ERROR(-20002, 'La dette mensuelle dépasse 50% du revenu mensuel moyen. Opération refusée.');
    END IF;
END;
/


CREATE OR REPLACE TRIGGER trg_deliquency_bankruptcy_message
AFTER INSERT ON deliquency
FOR EACH ROW
BEGIN
    -- Générer un message en fonction des antécédents de faillite du client
    IF TO_NUMBER(:NEW.Bankruptcies) > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Le client ' || :NEW.customer_id || ' a des antécédents de faillite.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Le client ' || :NEW.customer_id || ' n\'a pas d\'antécédents de faillite.');
    END IF;
END;
/


CREATE OR REPLACE FUNCTION get_banker_experience_level(p_banker_id VARCHAR2)
RETURN VARCHAR2 IS
    v_experience NUMBER;
    v_level VARCHAR2(10);
BEGIN
    -- Récupérer les années d'expérience du banquier
    SELECT TO_NUMBER(Years_of_Experiences)
      INTO v_experience
      FROM Banker
      WHERE Banker_id = p_banker_id;

    -- Déterminer le niveau d'expérience
    IF v_experience > 10 THEN
        v_level := 'Senior';
    ELSE
        v_level := 'Junior';
    END IF;

    RETURN v_level;
END;
/


CREATE OR REPLACE FUNCTION get_customer_debt_ratio(p_customer_id VARCHAR2)
RETURN NUMBER IS
    v_annual_income NUMBER;
    v_monthly_debt NUMBER;
    v_ratio NUMBER;
BEGIN
    -- Récupérer le revenu annuel et la dette mensuelle du client
    SELECT TO_NUMBER(Annual_Income)
      INTO v_annual_income
      FROM customers
      WHERE customer_id = p_customer_id;

    SELECT TO_NUMBER(Monthly_Debt)
      INTO v_monthly_debt
      FROM Financial_Obligations
      WHERE customer_id = p_customer_id;

    -- Vérifier la validité des données
    IF v_annual_income IS NULL OR v_annual_income = 0 THEN
        RETURN NULL;
    END IF;

    -- Calculer le ratio dette/revenu
    v_ratio := v_monthly_debt / (v_annual_income / 12);

    RETURN v_ratio;
END;
/


CREATE OR REPLACE FUNCTION get_number_of_open_accounts(p_customer_id VARCHAR2)
RETURN NUMBER IS
    v_open_accounts NUMBER;
BEGIN
    BEGIN
        -- Récupérer le nombre de comptes ouverts pour le client
        SELECT TO_NUMBER(Number_of_Open_Accounts)
          INTO v_open_accounts
          FROM credit_history
          WHERE customer_id = p_customer_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Si aucun compte n'est trouvé, retourner 0
            v_open_accounts := 0;
    END;

    RETURN v_open_accounts;
END;
/
