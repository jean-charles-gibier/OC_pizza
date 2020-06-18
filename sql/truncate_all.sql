SET FOREIGN_KEY_CHECKS=0;

truncate table address                ;
truncate table category              ;
truncate table employee              ;
truncate table employee_has_role     ;
truncate table ingredient            ;
truncate table invoice               ;
truncate table invoice_has_order     ;
truncate table menu                  ;
truncate table menu_item             ;
truncate table `order`                ;
truncate table order_has_menu_item   ;
truncate table order_has_person      ;
truncate table person                ;
truncate table pizzeria              ;
truncate table recipe               ;
truncate table recipe_has_ingredient;
truncate table role                  ;
truncate table statut                ;
truncate table stock_ingredient      ;
truncate table unity                 ;
truncate table address_has_pizzeria ;
SET FOREIGN_KEY_CHECKS=1;