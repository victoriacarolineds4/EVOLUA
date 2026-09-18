-- 01_pillars.sql — UPDATE dos 7 pilares (mantém IDs)

update public.pillars set name = 'Organização e Rotina', description = 'Como a pessoa organiza suas atividades, administra seu tempo, estabelece prioridades e conduz sua rotina profissional.' where id = '10000000-0000-0000-0000-000000000001'; -- era: Autogestão
update public.pillars set name = 'Responsabilidade', description = 'Como a pessoa reage diante de erros, atrasos, consequências e responsabilidades.' where id = '10000000-0000-0000-0000-000000000002'; -- era: Comunicação
update public.pillars set name = 'Aprendizagem e Mudança', description = 'Como a pessoa reage a mudanças, novas tarefas, feedbacks e processos de aprendizagem.' where id = '10000000-0000-0000-0000-000000000003'; -- era: Relacionamento
update public.pillars set name = 'Relacionamentos', description = 'Como a pessoa se relaciona com colegas, diferenças, conflitos e situações de colaboração.' where id = '10000000-0000-0000-0000-000000000004'; -- era: Orientação a Resultados
update public.pillars set name = 'Comunicação', description = 'Como a pessoa transmite informações, apresenta ideias, comunica problemas, pede ajuda e orienta outras pessoas.' where id = '10000000-0000-0000-0000-000000000005'; -- era: Liderança
update public.pillars set name = 'Pressão e Decisão', description = 'Como a pessoa reage diante de pressão, múltiplas demandas, problemas e decisões.' where id = '10000000-0000-0000-0000-000000000006'; -- era: Inovação e Adaptação
update public.pillars set name = 'Crescimento e Ética', description = 'Como a pessoa reage diante de oportunidades de crescimento, autonomia, desenvolvimento de outras pessoas e situações que envolvem escolhas éticas.' where id = '10000000-0000-0000-0000-000000000007'; -- era: Desenvolvimento Contínuo
