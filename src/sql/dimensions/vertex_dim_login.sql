create or replace view vertex_dim_login as
with facebook_info as (
select 	
        user_id,
        status as facebook_connect_status,
	create_time as facebook_connect_time
from
        verse.verse_ods_kiva_facebook_user
group by
        user_id,status,create_time
)
select
	l.id,
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
	com.sendAutolendingNotifications,
	-- facebook
	face.facebook_connect_status,
	face.facebook_connect_time,
	-- invitations
	inv.inviter_id as inviter_login_id,
	inv.id as invitation_id
	
from verse.verse_ods_kiva_login l
inner join verse.verse_ods_kiva_login_fund_account_mapper lfam on l.id = lfam.login_id
inner join verse.verse_ods_kiva_fund_account fa on lfam.fund_account_id = fa.id
left join verse.verse_ods_kiva_person person on  l.person_id = person.id
left join verse.verse_ods_kiva_communication_settings com on com.login_id = l.id
left join facebook_info face on face.user_id = l.id
left join verse.verse_ods_kiva_invitation inv on inv.invitee_id = l.id
where lfam.is_default_account = 'yes'
	and fa.type_id = 1 -- LENDER_FUND_ACCOUNT_TYPE_ID
	




