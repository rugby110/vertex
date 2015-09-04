create or replace view vertex_dim_login as
with facebook_info as (
select 	
        user_id,
        status as facebook_connect_status,
	create_time as facebook_connect_time
from
        facebook_user
group by
        user_id,status,create_time
)
select
	l.id as login_id,
	lfam.fund_account_id as default_fund_account_id,
	l.username,
	l.permanent_name,
	l.display_name,
	person.firstName,
	person.lastName,
	person.gender,
	l.visibility='anonymous' as is_anonymous,
	l.is_frozen='yes' as is_frozen,
	l.type,
	l.username like 'KivaCorporateUser%' as is_corporate,
	l.created_as_guest='yes' as created_as_guest,
	l.lender_page_id,
	l.person_id,
	l.default_team_id,
	l.create_time as registration_time,
	TO_CHAR(TO_TIMESTAMP(l.create_time), 'YYYYMMDD')::INT as registration_day_id,
	l.last_login_time,
	TO_CHAR(TO_TIMESTAMP(l.last_login_time), 'YYYYMMDD')::INT as last_login_day_id,
	-- communications settings
	com.medium, 
	com.sendKivaNews, 
	com.sendBizUpdate, 
	com.sendTeamMessages, 
	com.sendLenderMessages, 
	com.invitee_became_active, 
	com.relisted_loan, 
	com.expiration_warning, 
	com.nonlender_reminder, 
	com.loan_comment, 
	com.sendRepaymentNotifications,  
	com.sendAutolendingNotifications,
	-- facebook
	face.facebook_connect_status,
	face.facebook_connect_time,
	-- invitations
	inv.inviter_id as inviter_login_id,
	inv.id as invitation_id,
	-- first_item_category
        case
            when 
                fday.gift_redemption_first_day_id = fday.cc_all_first_day_id AND
                (fday.promo_loan_credit_first_day_id <> fday.cc_all_first_day_id OR fday.promo_loan_credit_first_day_id IS NULL) AND
                (fday.fundpool_match_first_day_id <> fday.cc_all_first_day_id OR fday.fundpool_match_first_day_id IS NULL) AND
                (fday.kivapool_match_first_day_id <> fday.cc_all_first_day_id OR fday.kivapool_match_first_day_id  IS NULL)
            then 'Kiva Card Redeemer'
            when
                fday.gift_redemption_first_day_id = fday.cc_all_first_day_id AND
                fday.promo_loan_credit_first_day_id = fday.cc_all_first_day_id
            then 'Kiva Card Partial Promo Redeemer'
            when
                fday.loan_purchase_first_day_id = fday.cc_all_first_day_id AND
                (fday.promo_loan_credit_first_day_id = fday.cc_all_first_day_id OR 
                        fday.fundpool_match_first_day_id = fday.cc_all_first_day_id OR 
                        fday.kivapool_match_first_day_id = fday.cc_all_first_day_id) AND
                (fday.deposit_first_day_id <> fday.cc_all_first_day_id OR fday.deposit_first_day_id IS NULL)
            then 'Promo Lender'
            when
                fday.donation_first_day_id = fday.cc_all_first_day_id AND
                (fday.loan_purchase_first_day_id <> fday.cc_all_first_day_id OR fday.loan_purchase_first_day_id IS NULL) AND
                (gift_purchase_first_day_id <> fday.cc_all_first_day_id OR gift_purchase_first_day_id IS NULL)
            then 'Donor'
            when
                fday.deposit_first_day_id = fday.cc_all_first_day_id AND
                gift_purchase_first_day_id = fday.cc_all_first_day_id AND
                (fday.donation_first_day_id <> fday.cc_all_first_day_id OR fday.donation_first_day_id IS NULL)
            then 'Depositor - Kiva Card NonDonor'
            when
                fday.deposit_first_day_id = fday.cc_all_first_day_id AND
                fday.gift_purchase_first_day_id = fday.cc_all_first_day_id AND
                fday.donation_first_day_id = fday.cc_all_first_day_id
            then 'Depositor - Kiva Card Donor'
            when
                fday.deposit_first_day_id = fday.cc_all_first_day_id AND
                fday.donation_first_day_id = fday.cc_all_first_day_id AND
                fday.loan_purchase_first_day_id = fday.cc_all_first_day_id
            then 'Depositor - Lender Donor'
            when
                fday.deposit_first_day_id = fday.cc_all_first_day_id AND
                fday.loan_purchase_first_day_id = fday.cc_all_first_day_id AND
                (fday.donation_first_day_id <> fday.cc_all_first_day_id OR fday.donation_first_day_id IS NULL)
            then 'Depositor - Lender NonDonor'
            when
                fday.deposit_first_day_id = fday.cc_all_first_day_id AND
                (fday.loan_purchase_first_day_id <> fday.cc_all_first_day_id OR fday.loan_purchase_first_day_id IS NULL)
            then 'Depositor - Other'
            when
                 fday.cc_all_first_day_id IS NULL OR fday.cc_all_first_day_id = 0
            then 'Zombie'
            else 'Other'
        end AS first_item_category
	
from login l
inner join login_fund_account_mapper lfam on l.id = lfam.login_id
inner join fund_account fa on lfam.fund_account_id = fa.id
left join vertex_dim_fund_account_first_day_ids fday on fday.fund_account_id = fa.id
left join person person on  l.person_id = person.id
left join communication_settings com on com.login_id = l.id
left join facebook_info face on face.user_id = l.id
left join invitation inv on inv.invitee_id = l.id
where lfam.is_default_account = 'yes'
	and fa.type_id = 1 -- LENDER_FUND_ACCOUNT_TYPE_ID
	



