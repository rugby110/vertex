create or replace view vertex_dim_login as
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
	l.last_login_time,
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
	com.sendAutolendingNotifications

from verse.verse_ods_kiva_login l
inner join verse.verse_ods_kiva_login_fund_account_mapper lfam on l.id = lfam.login_id
inner join verse.verse_ods_kiva_fund_account fa on lfam.fund_account_id = fa.id
left join verse.verse_ods_kiva_person person on  l.person_id = person.id
left join verse.verse_ods_kiva_communication_settings com on com.login_id = l.id
where lfam.is_default_account = 'yes'
	and fa.type_id = 1 -- LENDER_FUND_ACCOUNT_TYPE_ID
--limit 10
/*
select count(*)
from verse.verse_ods_kiva_login l
where l.username like 'KivaCorporateUser%'

select count(*)
from vertex_dim_login l
where is_corporate=true
*/
