# Configuring Notification

## Create a channel
1. To create a channel, open the Operations console and navigate to Administration -> Notifications.
1. Right-click and select New Channel, E-Mail (SMTP). E-mail is the preferred channel for most notifications in Operations Manager.
1. Use the following properties when creating the channel:
    - SMTP server: LON-EX1.adatum.com
    - Return address: SCOM_noreply@Adatum.com
    - retry interval: 5 (default)
1. You can configure the E-mail subject, E-mail message, Importance, and Encoding for this channel. You can customize each field based on your requirements for the channel, including altering the email message itself.
1. Leave all options default and select **Finish**.

## Create a subscriber
Before you can configure alerts and monitors to send data via email, you must configure a subscriber that includes an address to which to send emails. Follow these steps:
1. Navigate to Administration -> Notifications. Right-click and select **New Subscriber**. This opens the Notification Subscriber Wizard.
1. Begin by naming the new recipient. The easiest way to do this is searching Active Directory (AD). (If the user does not exist in AD, you must enter the information manually.) Click the ... button to browse the directory. Type the user’s name and click the Check Names button to validate your entry. Use Administrator in this case.
1. Click OK.
1. The user’s account name now displays in the subscriber name field. On this second page, you can also choose to configure a schedule for sending emails.
1. For this example assume notifications will always be sent and accept the defaults on the page. You can use schedules to allow notifications during specific time ranges by a date range, weekly recurrence, selected days of the week, and based upon a specific time zone. This is most frequently used when providing one form of notification during business hours and another form of notification outside business hours.
1. Click Next.
1. Click Add to start the Subscriber Address Wizard.
1. Specify the name of the subscriber on the General page such as Database Administrators.
1. Choose the channel type you want for your subscriber, such as the E-Mail (SMTP) channel. Specify the delivery address to send the subscription to. Note you can add individual email addresses as individual subscribers, or you can add distribution lists, using Microsoft Exchange to maintain the membership of the distribution list.
1. Specify the schedule for the subscriber and click Finish to complete the wizard.
> You can configure scheduling for the subscriber or for the subscription. The schedule applies to all subscribers within the subscription. This example illustrated how to set a business day schedule for the subscriber so alerts would only be sent during those hours. You can configure the subscription to send during any hours, and different addresses could be specified to send emails during business hours and a pager notification off-hours.

## Create a subscription
After creating a subscriber, you must create a subscription for the recipient to get email alerts. Perform the following steps:
1. In the Administration space, navigate to Notifications -> Subscriptions.
1. Right-click and select **New Notification Subscription**.
1. Name of the subscription: **Alerting to Database Admins**.
1. Click Next.
1. Ignore the subscription scope and click Next.
1. The Criteria page identifies the criteria applied to determine if a subscription will include an alert. Multiple conditions can be applied as part of the subscription criteria. As an example for commonly used criteria, create a subscription that sends all critical severity alerts. Click Insert, Expression.
1. Use the following values: 
  1. Criteria: Severity
  1. Operator: Equals
  1. Value: Critical
1. Select Next.
1. You can define new subscribers in the Notification Subscription Wizard or add existing subscribers to the subscription at this point. For this example, click Add and Search to add the **Database Administrators** subscriber defined in the previous section. 
1. Click Next.
1. On the Channels portion of the Notification Subscription Wizard you can create new channels, add existing channels, and configure alert aging. For this example, configure the previously created SMTP channel.
1. **Note.** The benefit to using a custom channel is you can customize the channel to send alerts from a different return address, letting you define Outlook rules to route those emails into a specific folder based on the return address.
1. The summary page of the Notification Subscription Wizard provides the summary of the subscription you created and a check box (checked by default) to enable the subscription. Click Finish.

> Please notice we're not able to send e-mails from our training environment.
