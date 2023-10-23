## What is user authentication and user authorization?

Future reference: https://oauth.net/articles/authentication/

When you visit https://mail.google.com or https://outlook.live.com you want to see your emails. If you use your mobile phone or desktop email applications you want to see your emails. These applications do not know who "you " are. You need to convince the software of who you are. The real you. 100% authentic you. To the software, you are a User. All your emails - sent and received - are linked within the software to your User account. Most typically when you open a website or software you will indicate which user account is your with an email address or username. You will then provide a password - known only to you and the software - that authenticates that you have access to this User account.

Once you have authenticated which User account you want to access, the software needs to determine how much functionality and data to give you access to. Low hanging fruit - you would be authorized to view the emails you have sent or received.

Authorization also has a different meaning. If you read your emails through a mobile or desktop application then initially this software does not have permission to access your email. You will need to authenticate as you, and to authorize the email program to access your emails and to send new emails on your behalf. The email program does not really need your password, it only needs authorization. The benefit of granting authorization to an email program is that you could revoke the permission. Another benefit is that the email program cannot accidentally nor maliciously share access to your emails. You've only given authorization to this email application. A different application or email client would need to ask you for authorization. The email program cannot be hacked and leak your password since it never received the password. If the email client software is subsequently deemed to be a bad actor, then https://mail.google.com or https://outlook.live.com could revoke all permissions for it to access any user's accounts simultaneously.

This decoupling of user authentication and authorization - of users (you and me) of web applications (say of https://mail.google.com or https://outlook.live.com) of a granting authorization to third-party software (say email clients written by Google, Microsoft, or any other software vendor or websites) to a subset of functionality and data (perhaps an email client is only able to read your Google emails, but not your Google calendar entries or Google documents) - is most commonly implemented using OAuth2. We will come back to the wheres and hows and whys of OAuth2 later when its more interesting to do so.

The UAA (named for User Authentication & Authorization) is a free, open source software program backed by a simple SQL database of your choice that you can use as the backbone of implementing and administrating user authentication and authorization across one or more applications that might share similar users and organizations. It was first released in 2011 and has been the stoic backbone of user authentication and authorization in Cloud Foundry, BOSH, and CredHub. It is visible within shared public Cloud Foundry distributions (for example, https://login.run.pivotal.io, https://login.fr.cloud.gov/login, and https://www.predix.io/login) and also operates within private Cloud Foundry deployments at hundreds of large companies around the world.

It can be used within your company too. With the UAA you can delegate the creation of users, their roles within your organization/customer base, and their permissions within your applications. The UAA can be a bridge to other sources of truth about your users and their roles and permissions, such as Microsoft Active Directory.

With the UAA you can allow users to authenticate with simple passwords, with tokens, and with multi-factor authentication. Users can authorize programs to access their data in other programs.

This book is a tutorial to learn how to use it, how to integrate it into your software, and how to deploy it and upgrade it.

## Why *not* use the UAA?

Whilst the UAA is a solution to several critical problems it is not the only solution. If your web applications or mobile applications have user accounts and login pages then you have already solved some of the user authentication and authorization problems already.

If you've delegated some then you might have delegated them to GitHub, Google Accounts, Microsoft Active Directory, Facebook, Twitter, or some other pre-existing system that will tell your site that a user is a specific user.

As an example, I want to use your application and you allow me to authenticate to your application via GitHub. That is, you ask GitHub to prove who I am and allow GitHub to tell you my personal information.

On your site I click your "Login via GitHub" button.

I would be redirected to https://github.com/ to first login if I were not already signed in. As Dr Nic Williams, I would login to GitHub as [@drnic](https://github.com/drnic). Since only I know my GitHub password, GitHub trusts that the `@drnic` account is me. Except GitHub doesn't truly trust me, so it asks me for a second form of proof. I take out my phone, open the Authy application (or another like Google Authenticator) and copy in a 6 digit number. Finally GitHub believes that `@drnic` is me using two factors of authentication (2FA) - my password and my code from my phone.

Next, GitHub asks me if I grant your application permission - authorization - to access my GitHub account. Your application only wants my personal profile information - my name and email - and so that is all I am asked to authorize. I click "Authorize".

GitHub now redirects me back to your web application or mobile application. Your application is given my personal information - my email and name - and your application respects GitHub's decision and the information it receives from GitHub. If GitHub believes that I am `@drnic` and my name is "Dr Nic Williams", then your application believes it too. Your application never has to ask me for my name nor email.

Your example application also supports organizations - as a user I can see and edit content only within teams/organizations that I belong to.

Instead of your development team spending a lot of time implementing its own UI and business logic for organizations - how to invite and revoke people from teams - you defer again to GitHub. When GitHub redirected me back to your application, it also told you which GitHub organizations I am a member of, and which teams of each organization. For example, I am a member of the [@starkandwayne](https://github.com/starkandwayne) - an excellent consultancy for Cloud Foundry, Kubernetes, and enterprise cloud systems. Your application also has a `@starkandwayne` organization so I am automatically granted permission (authorization) to read and modify its contents within your application.

If not Github, your application might use Google Accounts (`drnic@starkandwayne.com` belongs to a `@starkandwayne.com` Google Account) or an in-house Microsoft Active Directory organization.

In all these variations your application does not have to touch or store or rotate passwords or two-factor authentication systems. It does not have to implement UIs for the management of membership of organizations/teams. And anything you didn't have to implement is something you don't have to continually maintain over the next decade. You've kept your application simpler, and thus its behavior is more well known to more people.

## Why did I write this book?

The UAA was first written to be a component of Cloud Foundry for its 2011 public open source release. I've watched or been heavily involved with Cloud Foundry since that time, over 7 years ago from 2018 at the time of writing, and yet I never truly understood the UAA. It just worked. I thought, what was to truly know?

If I logged into Cloud Foundry with its CLI - `cf login` or `cf auth` - then I knew the UAA was involved. If I logged into [Pivotal Web Service](https://run.pivotal.io), [GE Predix](https://http://predix.io/), [Swisscom Cloud](http://cloud.swisscom.com/), or any other public or private Cloud Foundry, then I was visibly redirected to the UAA (often it has the subdomain `login`, for example https://login.run.pivotal.io/) prior to be returned to a Cloud Foundry web console. A few years ago the UAA popped up inside of BOSH and then CredHub, but I was never troubled by more than the extra RAM requirements of running the additional Java/Tomcat process that is the UAA.

I knew the ideas behind "Single Sign On" (SSO), OAuth2, and OpenID; but I had never been required to get my hands dirty and write a client application from scratch that integrated with the UAA. I had never had to integrate the UAA with backed user address books such as Microsoft Active Directory. I had never had to setup users and permissions with the UAA. Someone else always seemed to get around to tasks relating to the UAA before I did.

Many aspects of the UAA were still unknown to me.

The UAA was written in Java and used the web framework Spring; the former I disliked, and the latter was a huge learning curve for the sole purpose of being able to read the UAA source code.

The UAA web interface was also never aesthetically pleasing; was not visited for very long by users, nor did users ever choose to visit the UAA: you would try to visit a website, your user session would have expired and were redirected to the UAA against your will, you entered your username and password, and were then quickly returned to the actual website you were trying to use.

The UAA web interface does not perform any administration or configuration functions. It only allows people to sign in, to setup and use multi-factor authentication (also known as MFA, two-factor authentication, or 2FA), to confirm that a third-party application is allowed to access their UAA personal information, or to revoke that permission at a later time.

An administration user must interact with the UAA API or use a primitive CLI to add or modify users and third-party client applications. APIs and low-level CLIs are fantastic for power users, but they are not very welcoming to myself: a brand-new user for seven years in a row.

The UAA could be the user authentication (who am I?) and authorization (what am I allowed to do?) backend for every web application or API, but I don't feel like the UAA team, its sponsors (primarily Pivotal), nor the Cloud Foundry Foundation do the UAA justice and promote it for such a broad mission. It has no dedicated marketing site to learn more, nor a simple Docker image to get started.

But I could see the wide reaching potential for the UAA beyond Cloud Foundry; as I'm sure many people do who've explicitly noticed the UAA. It is incredibly powerful, it has a well documented API, it is open source, it is written in a popular web framework (Spring), and it is free. It could be a huge boon to software developers and systems administrators around the world.

So I sat down to explain the UAA to myself with a sequence of tutorials that I wished were written for me, and I hope are now useful to you and your work friends.

Along the way I wrote the `uaa-deployment` CLI to make it much easier to deploy the UAA locally and to any cloud (Amazon Web Services, Google Compute, Microsoft Azure, VMWare vSphere, OpenStack, and more).

I hope you discover the incredible power of the UAA and learn to feel empowered to delegate to it all your user authentication and authorization needs. Once you start using the UAA there will be so much that you no longer have to implement, or have to apologise for not having implemented yet.

## Pronunciation, Spelling, and Grammar

In my head I pronounce UAA "You Aye Aye", rather than "You Ah", or "User Authentication and Authorization". As such, in the text of this book you'll see me writing "a UAA", rather than "an UAA". It sounds better.

The author of this book, Dr Nic Williams, is many things and these affect and confuse his decisions around the grammar used in this book.

He has a PhD in Computer Science from the University of Queensland, Australia - so he's had academic papers and long-form theses reviewed by supervisors who delight in correcting academic grammar.

He is CEO of Stark & Wayne, a pioneering and premier consultancy for all things Cloud Foundry, BOSH, Kubernetes, Concourse CI, and UAA. So he is the author of many emails and chat room comments that are not anchored by formal grammar rules.

He is the author of hundreds of blog posts over the last ten years. He is fortunate to have friends and coworkers who proof read his blog posts, and sometimes they are so shocked by his abuses of any known forms of grammar that they must object and ask for improvements.

He is the author of hundreds of open source projects, each with their own README and documentation. He is generally suspicious that no one reads the English text between code examples.

He is the author of two online books - [Concourse Tutorial](https://concoursetutorial.com) and [Ultimate Guide to BOSH](https://ultimateguidetobosh.com) - that have both received much praise from readers, and receive much errata in the form of dozens of GitHub Pull Requests to correct spelling, grammar, and code examples.

He is Australian. His formative education was Australia, which includes soft fork of Queen's English. He is comfortable in the nurturing embrace of English words spelled as the Queen wishes them spelled. Dear reader, please realise three things: Lego not Legos, colour not color, and the [Oxford Comma could save you $13m](http://www.abc.net.au/news/2017-03-21/the-case-of-the-$13-million-comma/8372956).

We at Stark & Wayne are a diverse mixture of America, Canadian, Dutch, Chinese, German, and Australian. But in this book, let's pick one English dictionary and grammar. Mine. I mean, the Queen of England's.

If you spot a missspelling, please you are welcome to click the Edit pencil at the top of each page and correct it.

If you spot bad grammar, wafflingly long sentences or a list of two or more items that do not end with an Oxford Comma then please click the Edit pencil at the top and offer to correct it. I really appreciate it.

If you spot deliberate irony, like deliberate mistakes as examples then you can smile and move on.
