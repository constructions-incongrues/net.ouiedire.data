--
-- Dumping data for table `directus_users`
--

LOCK TABLES `directus_users` WRITE;
/*!40000 ALTER TABLE `directus_users` DISABLE KEYS */;
INSERT INTO `directus_users` (`id`, `status`, `role`, `first_name`, `last_name`, `email`, `password`, `token`, `timezone`, `locale`, `locale_options`, `avatar`, `company`, `title`, `email_notifications`, `last_access_on`, `last_page`, `external_id`, `theme`, `2fa_secret`, `password_reset_token`) VALUES
(1,	'active',	1,	'Admin',	'User',	'admin@data.ouiedire.net',	'$2y$10$21dK1mUg2z1tUVk05Qpnuez4dxudLxcRxvvAWxDCGFPQlByOhdPBi',	NULL,	'Europe/Paris',	'fr-FR',	NULL,	NULL,	NULL,	NULL,	1,	NULL,	NULL,	NULL,	'auto',	NULL,	NULL);
/*!40000 ALTER TABLE `directus_users` ENABLE KEYS */;
UNLOCK TABLES;