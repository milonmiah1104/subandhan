# সুবন্ধন (Subandhan)

সুবন্ধনের responsive matchmaking portal-এর প্রাথমিক সংস্করণ।

## সংযুক্ত পরিষেবা
- Supabase Project URL: https://xlwrqjxatoggtmlnjevp.supabase.co
- Project ID: xlwrqjxatoggtmlnjevp
- Database schema Supabase-এ প্রয়োগ করা হয়েছে; RLS সক্রিয়।
- Browser-এ শুধু publishable key ব্যবহৃত হয়। কখনোই service-role/secret key প্রকাশ করবেন না।

## বৈশিষ্ট্য
- ইমেইল/পাসওয়ার্ড দিয়ে নিবন্ধন ও লগইন
- পাত্র/পাত্রীর বায়োডাটা জমা এবং Admin approval
- অনুমোদিত প্রোফাইল খোঁজা
- পরিচিতির/ম্যাচিং অনুরোধ
- ফোন ও অভিভাবকের ইমেইল আলাদা private table-এ রাখা
- responsive বাংলা UI; পূর্ণ ইংরেজি UI এবং ছবি আপলোড পরবর্তী উন্নয়ন

## GitHub Pages প্রকাশ
1. Repository → Settings → Pages খুলুন।
2. Build and deployment-এ **Deploy from a branch** নির্বাচন করুন।
3. Branch **main**, folder **/(root)** দিয়ে Save করুন।
4. প্রকাশ হলে URL হবে: https://milonmiah1104.github.io/subandhan/
5. Supabase → Authentication → URL Configuration-এ Site URL হিসেবে ওই ঠিকানা দিন এবং Redirect URLs-এ একই ঠিকানা যোগ করুন।

## প্রথম Admin তৈরি
1. প্রকাশিত সাইটে নিজের ইমেইল দিয়ে account তৈরি করুন এবং ইমেইল নিশ্চিত করুন।
2. Supabase → SQL Editor-এ নিচের SQL-এ YOUR_EMAIL_HERE-এর জায়গায় আপনার account-এর ইমেইল বসিয়ে চালান:

```sql
insert into public.user_roles(user_id, role)
select id, 'admin' from auth.users
where lower(email)=lower('YOUR_EMAIL_HERE')
on conflict (user_id) do update set role='admin';
```

3. সাইট থেকে logout করে আবার login করুন।

## গুরুত্বপূর্ণ
- এটি প্রাথমিক সংস্করণ; প্রকাশের আগে নিরাপত্তা ও বাস্তব ব্যবহারকারীর প্রবাহ পরীক্ষা করা প্রয়োজন।
- ছবির আপলোড এখনো চালু নেই।
- ব্যক্তিগত তথ্য বা পাসওয়ার্ড কারও সঙ্গে শেয়ার করবেন না।
- Free plan-এ usage, storage ও bandwidth সীমা থাকতে পারে। কোনো পেইড সুবিধা চালু করার আগে মূল্য যাচাই করুন।
