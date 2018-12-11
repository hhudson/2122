set serveroutput on
SET DEFINE OFF
/
INSERT INTO BLOG_EMAIL_TEMPLATE (TEMPLATE_ID) VALUES (46237);
/
declare
l_response clob;
l_html clob;
l_body clob;
begin

l_body := '{"name":"090718 Template","html":"<!DOCTYPE html PUBLIC \"-\/\/W3C\/\/DTD XHTML 1.0 Transitional\/\/EN\" \"http:\/\/www.w3.org\/TR\/xhtml1\/DTD\/xhtml1-transitional.dtd\">\n<html>\n    <head>\n        <meta http-equiv=\"Content-Type\" content=\"text\/html; charset=UTF-8\">\n        \n        <meta property=\"og:title\" content=\"*|MC:SUBJECT|*\">\n        \n        <title>*|MC:SUBJECT|*<\/title>\n\t\t\n\t<style type=\"text\/css\">\n\t\t#outlook a{\n\t\t\tpadding:0;\n\t\t}\n\t\tbody{\n\t\t\twidth:100% !important;\n\t\t}\n\t\tbody{\n\t\t\t-webkit-text-size-adjust:none;\n\t\t}\n\t\tbody{\n\t\t\tmargin:0;\n\t\t\tpadding:0;\n\t\t}\n\t\timg{\n\t\t\tborder:none;\n\t\t\tfont-size:14px;\n\t\t\tfont-weight:bold;\n\t\t\theight:auto;\n\t\t\tline-height:100%;\n\t\t\toutline:none;\n\t\t\ttext-decoration:none;\n\t\t\ttext-transform:capitalize;\n\t\t}\n\t\t#backgroundTable{\n\t\t\theight:100% !important;\n\t\t\tmargin:0;\n\t\t\tpadding:0;\n\t\t\twidth:100% !important;\n\t\t}\n\t\tbody,.backgroundTable{\n\t\t\tbackground-color:#FAFAFA;\n\t\t}\n\t\t#templateContainer{\n\t\t\tborder:1px solid #DDDDDD;\n\t\t}\n\t\th1,.h1{\n\t\t\tcolor:#202020;\n\t\t\tdisplay:block;\n\t\t\tfont-family:Arial;\n\t\t\tfont-size:34px;\n\t\t\tfont-weight:bold;\n\t\t\tline-height:100%;\n\t\t\tmargin-bottom:10px;\n\t\t\ttext-align:left;\n\t\t}\n\t\th2,.h2{\n\t\t\tcolor:#202020;\n\t\t\tdisplay:block;\n\t\t\tfont-family:Arial;\n\t\t\tfont-size:30px;\n\t\t\tfont-weight:bold;\n\t\t\tline-height:100%;\n\t\t\tmargin-bottom:10px;\n\t\t\ttext-align:left;\n\t\t}\n\t\th3,.h3{\n\t\t\tcolor:#202020;\n\t\t\tdisplay:block;\n\t\t\tfont-family:Arial;\n\t\t\tfont-size:26px;\n\t\t\tfont-weight:bold;\n\t\t\tline-height:100%;\n\t\t\tmargin-bottom:10px;\n\t\t\ttext-align:left;\n\t\t}\n\t\th4,.h4{\n\t\t\tcolor:#202020;\n\t\t\tdisplay:block;\n\t\t\tfont-family:Arial;\n\t\t\tfont-size:22px;\n\t\t\tfont-weight:bold;\n\t\t\tline-height:100%;\n\t\t\tmargin-bottom:10px;\n\t\t\ttext-align:left;\n\t\t}\n\t\t#templatePreheader{\n\t\t\tbackground-color:#FAFAFA;\n\t\t}\n\t\t.preheaderContent div{\n\t\t\tcolor:#505050;\n\t\t\tfont-family:Arial;\n\t\t\tfont-size:10px;\n\t\t\tline-height:100%;\n\t\t\ttext-align:left;\n\t\t}\n\t\t.preheaderContent div a:link,.preheaderContent div a:visited{\n\t\t\tcolor:#336699;\n\t\t\tfont-weight:normal;\n\t\t\ttext-decoration:underline;\n\t\t}\n\t\t.preheaderContent div img{\n\t\t\theight:auto;\n\t\t\tmax-width:600px;\n\t\t}\n\t\t#templateHeader{\n\t\t\tbackground-color:#FFFFFF;\n\t\t\tborder-bottom:0;\n\t\t}\n\t\t.headerContent{\n\t\t\tcolor:#202020;\n\t\t\tfont-family:Arial;\n\t\t\tfont-size:34px;\n\t\t\tfont-weight:bold;\n\t\t\tline-height:100%;\n\t\t\tpadding:0;\n\t\t\ttext-align:center;\n\t\t\tvertical-align:middle;\n\t\t}\n\t\t.headerContent a:link,.headerContent a:visited{\n\t\t\tcolor:#336699;\n\t\t\tfont-weight:normal;\n\t\t\ttext-decoration:underline;\n\t\t}\n\t\t#headerImage{\n\t\t\theight:auto;\n\t\t\tmax-width:600px !important;\n\t\t}\n\t\t#templateContainer,.bodyContent{\n\t\t\tbackground-color:#FDFDFD;\n\t\t}\n\t\t.bodyContent div{\n\t\t\tcolor:#505050;\n\t\t\tfont-family:Arial;\n\t\t\tfont-size:14px;\n\t\t\tline-height:150%;\n\t\t\ttext-align:left;\n\t\t}\n\t\t.bodyContent div a:link,.bodyContent div a:visited{\n\t\t\tcolor:#336699;\n\t\t\tfont-weight:normal;\n\t\t\ttext-decoration:underline;\n\t\t}\n\t\t.bodyContent img{\n\t\t\tdisplay:inline;\n\t\t\tmargin-bottom:10px;\n\t\t}\n\t\t#templateFooter{\n\t\t\tbackground-color:#FDFDFD;\n\t\t\tborder-top:0;\n\t\t}\n\t\t.footerContent div{\n\t\t\tcolor:#707070;\n\t\t\tfont-family:Arial;\n\t\t\tfont-size:12px;\n\t\t\tline-height:125%;\n\t\t\ttext-align:left;\n\t\t}\n\t\t.footerContent div a:link,.footerContent div a:visited{\n\t\t\tcolor:#336699;\n\t\t\tfont-weight:normal;\n\t\t\ttext-decoration:underline;\n\t\t}\n\t\t.footerContent img{\n\t\t\tdisplay:inline;\n\t\t}\n\t\t#social{\n\t\t\tbackground-color:#FAFAFA;\n\t\t\tborder:1px solid #F5F5F5;\n\t\t}\n\t\t#social div{\n\t\t\ttext-align:center;\n\t\t}\n\t\t#utility{\n\t\t\tbackground-color:#FDFDFD;\n\t\t\tborder-top:1px solid #F5F5F5;\n\t\t}\n\t\t#utility div{\n\t\t\ttext-align:center;\n\t\t}\n\t\t#monkeyRewards img{\n\t\t\tmax-width:160px;\n\t\t}\n<\/style><\/head>\n    <body leftmargin=\"0\" marginwidth=\"0\" topmargin=\"0\" marginheight=\"0\" offset=\"0\">\n    \t<center>\n        \t<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" height=\"100%\" width=\"100%\" id=\"backgroundTable\">\n            \t<tr>\n                \t<td align=\"center\" valign=\"top\">\n                        <table border=\"0\" cellpadding=\"10\" cellspacing=\"0\" width=\"600\" id=\"templatePreheader\">\n                            <tr>\n                                <td valign=\"top\" class=\"preheaderContent\">\n                                \n                                    <table border=\"0\" cellpadding=\"10\" cellspacing=\"0\" width=\"100%\">\n                                    \t<tr>\n                                        \t<td valign=\"top\">\n                                            \t<div mc:edit=\"std_preheader_content\">\n                                                \tUse one or two sentences in this area to offer a teaser of your email content. Text here will show in a preview area in some email clients.\n                                                <\/div>\n                                            <\/td>\n                                            <td valign=\"top\" width=\"180\">\n                                            \t<div mc:edit=\"std_preheader_links\">\n                                                \t<!-- *|IFNOT:ARCHIVE_PAGE|* -->Is this email not displaying correctly?<br><a href=\"*|ARCHIVE|*\" target=\"_blank\">View it in your browser<\/a>.<!-- *|END:IF|* -->\n                                                <\/div>\n                                            <\/td>\n                                        <\/tr>\n                                    <\/table>\n                                \n                                <\/td>\n                            <\/tr>\n                        <\/table>\n                    \t<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"600\" id=\"templateContainer\">\n                        \t<tr>\n                            \t<td align=\"center\" valign=\"top\">\n                                \t<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"600\" id=\"templateHeader\">\n                                        <tr>\n                                            <td class=\"headerContent\">\n                                            \n                                            \t<img src=\"http:\/\/gallery.mailchimp.com\/653153ae841fd11de66ad181a\/images\/placeholder_600.gif\" style=\"max-width:600px;\" id=\"headerImage campaign-icon\" mc:label=\"header_image\" mc:edit=\"header_image\" mc:allowdesigner=\"\" mc:allowtext=\"\">\n                                            \n                                            <\/td>\n                                        <\/tr>\n                                    <\/table>\n                                <\/td>\n                            <\/tr>\n                        \t<tr>\n                            \t<td align=\"center\" valign=\"top\">\n                                \t<table border=\"0\" cellpadding=\"10\" cellspacing=\"0\" width=\"600\" id=\"templateBody\">\n                                    \t<tr>\n                                            <td valign=\"top\" class=\"bodyContent\">\n                                \n                                                <table border=\"0\" cellpadding=\"10\" cellspacing=\"0\" width=\"100%\">\n                                                    <tr>\n                                                        <td valign=\"top\">\n                                                            <div mc:edit=\"std_content00\">\n                                                                <span class=\"h1\">Heading 1<\/span>\n                                                                <span class=\"h2\">Heading 2<\/span>\n                                                                <span class=\"h3\">Heading 3<\/span>\n                                                                <span class=\"h4\">Heading 4<\/span>\n                                                                <strong>Getting started:<\/strong> Customize your template by clicking on the style editor tabs up above. Set your fonts, colors, and styles. After setting your styling is all done you can click here in this area, delete the text, and start adding your own awesome content.\n                                                                <br>\n                                                                <br>\n                                                                After you enter your content, highlight the text you want to style and select the options you set in the style editor in the \"styles\" drop down box. Want to <a href=\"http:\/\/www.mailchimp.com\/kb\/article\/im-using-the-style-designer-and-i-cant-get-my-formatting-to-change\" target=\"_blank\">get rid of styling on a bit of text<\/a>, but having trouble doing it? Just use the \"clear styles\" button to strip the text of any formatting and reset your style.\n                                                            <\/div>\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t<\/td>\n                                                    <\/tr>\n                                                <\/table>                                              \n                                            <\/td>\n                                        <\/tr>\n                                    <\/table>\n                                <\/td>\n                            <\/tr>\n                        \t<tr>\n                            \t<td align=\"center\" valign=\"top\">\n                                \t<table border=\"0\" cellpadding=\"10\" cellspacing=\"0\" width=\"600\" id=\"templateFooter\">\n                                    \t<tr>\n                                        \t<td valign=\"top\" class=\"footerContent\">\n                                                <table border=\"0\" cellpadding=\"10\" cellspacing=\"0\" width=\"100%\">\n                                                    <tr>\n                                                        <td colspan=\"2\" valign=\"middle\" id=\"social\">\n                                                            <div mc:edit=\"std_social\">\n                                                                &nbsp;<a href=\"*|TWITTER:PROFILEURL|*\">follow on Twitter<\/a> | <a href=\"*|FACEBOOK:PROFILEURL|*\">friend on Facebook<\/a> | <a href=\"*|FORWARD|*\">forward to a friend<\/a>&nbsp;\n                                                            <\/div>\n                                                        <\/td>\n                                                    <\/tr>\n                                                    <tr>\n                                                        <td valign=\"top\" width=\"370\">\n                                                            <br>\n                                                            <div mc:edit=\"std_footer\">\n                                                                *|IF:LIST|*\n                                                                <em>Copyright &copy; *|CURRENT_YEAR|* *|LIST:COMPANY|*, All rights reserved.<\/em>\n                                                                <br>\n                                                                <!-- *|IFNOT:ARCHIVE_PAGE|* -->\n                                                                *|LIST:DESCRIPTION|*\n                                                                <br>\n                                                                <strong>Our mailing address is:<\/strong>\n                                                                <br>\n                                                                *|HTML:LIST_ADDRESS_HTML|*\n                                                                <br>\n                                                                <!-- *|END:IF|* -->\n                                                                *|ELSE:|*\n                                                                <!-- *|IFNOT:ARCHIVE_PAGE|* -->\n                                                                <em>Copyright &copy; *|CURRENT_YEAR|* *|USER:COMPANY|*, All rights reserved.<\/em>\n                                                                <br>\n                                                                <strong>Our mailing address is:<\/strong>\n                                                                <br>\n                                                                *|USER:ADDRESS_HTML|*\n                                                                <!-- *|END:IF|* -->\n                                                                *|END:IF|*\n                                                            <\/div>\n                                                            <br>\n                                                        <\/td>\n                                                        <td valign=\"top\" width=\"170\" id=\"monkeyRewards\">\n                                                            <br>\n                                                            <div mc:edit=\"monkeyrewards\">\n                                                                *|IF:REWARDS|* *|HTML:REWARDS|* *|END:IF|*\n                                                            <\/div>\n                                                            <br>\n                                                        <\/td>\n                                                    <\/tr>\n                                                    <tr>\n                                                        <td colspan=\"2\" valign=\"middle\" id=\"utility\">\n                                                            <div mc:edit=\"std_utility\">\n                                                                &nbsp;<a href=\"*|UNSUB|*\">unsubscribe from this list<\/a> | <a href=\"*|UPDATE_PROFILE|*\">update subscription preferences<\/a><!-- *|IFNOT:ARCHIVE_PAGE|* --> | <a href=\"*|ARCHIVE|*\">view email in browser<\/a><!-- *|END:IF|* -->&nbsp;\n                                                            <\/div>\n                                                        <\/td>\n                                                    <\/tr>\n                                                <\/table>\n                                            \n                                            <\/td>\n                                        <\/tr>\n                                    <\/table>\n                                <\/td>\n                            <\/tr>\n                        <\/table>\n                        <br>\n                    <\/td>\n                <\/tr>\n            <\/table>\n        <\/center>\n    <\/body>\n<\/html>"}';
--l_body := '{"name":"This is an updated Template name"}';

 l_response := apex_web_service.make_rest_request(
                  p_url         => 'https://us18.api.mailchimp.com/3.0/templates'
                , p_http_method => 'POST'
                , p_username    => 'admin'
                , p_password    => '186cc40d3bc8e3ce51d8ffe49452d676-us18'
                , p_body        => l_body
                , p_wallet_path => 'file:/home/oracle/orapki_wallet_nowc'
                , p_https_host  => 'wildcardsan2.mailchimp.com'
            );
dbms_output.put_line(l_response); -- 46237
end;
/
declare
l_response clob;
l_html clob;
l_body clob;
begin
select email_html
into l_html
from blog_email_template
where template_id = 39405;

--l_body := '{"name":"Test Template","html":"'||REPLACE(replace(l_html, CHR(13),''), CHR(10), '')||'"}';

l_body := '{"name":"Test Template","html":"<html><body>This is a really basic email./</body></html>"}';
--l_body := '{"name":"This is an updated Template name"}';

 l_response := apex_web_service.make_rest_request(
                  p_url         => 'https://us18.api.mailchimp.com/3.0/templates/46237'
                , p_http_method => 'PATCH'
                , p_username    => 'admin'
                , p_password    => '186cc40d3bc8e3ce51d8ffe49452d676-us18'
                , p_body        => l_body
                , p_wallet_path => 'file:/home/oracle/orapki_wallet_nowc'
                , p_https_host  => 'wildcardsan2.mailchimp.com'
            );
  dbms_output.put_line(l_response);
--dbms_output.put_line(l_body);
end;