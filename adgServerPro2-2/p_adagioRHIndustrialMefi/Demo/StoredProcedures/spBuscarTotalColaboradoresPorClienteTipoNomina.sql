USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc Demo.spBuscarTotalColaboradoresPorClienteTipoNomina as

	if object_id('tempdb..#tempTotalEmpClientes') is not null drop table #tempTotalEmpClientes;

	select e.IDCliente,e.Cliente,e.IDTipoNomina,e.TipoNomina,Count(*) as Total
	INTO #tempTotalEmpClientes
	from RH.tblEmpleadosMaster e
	group by e.IDCliente,e.Cliente,e.IDTipoNomina,e.TipoNomina

	--select * from Nomina.tblCatTipoNomina where IDCliente =12

	select * 
	from #tempTotalEmpClientes
	order by Cliente, TipoNomina, Total

	select * from RH.tblEmpleadosMaster where IDTipoNomina = 56

	--exec app.spBorradoFisicoColaborador @IDEmpleado = 1327

	--select * from RH.tblCatClientes

	/*
	IDCliente   Cliente                                            IDTipoNomina TipoNomina                                                                                           Total
	----------- -------------------------------------------------- ------------ ---------------------------------------------------------------------------------------------------- -----------
	1           ADAGIO INFORMATICA INTEGRAL SC                     4            QUINCENAL                                                                                            50
	1           ADAGIO INFORMATICA INTEGRAL SC                     24           SEMANAL                                                                                              50
	2           ALLIANCE SALES                                     8            QUINCENAL                                                                                            50
	2           ALLIANCE SALES                                     7            SEMANAL                                                                                              50
	10          BE HOTELES                                         15           QUINCENAL                                                                                            50
	10          BE HOTELES                                         15           SEMANAL																								 50
	12          OKUMA                                              62           QUINCENAL                                                                                            50
	12          OKUMA                                              17           SEMANAL                                                                                              50

	Eliminar
	19          COUGAR SA DE CV                                    56           SEMANAL                                                                                              1
	7           CUBIKO ASESORES E INSTRUCTORES                     12           SEMANAL                                                                                              3
	8           DOCTORES DE PALABRAS                               13           MENSUAL                                                                                              1
	9           DWIT MEXICO                                        14           SEMANAL                                                                                              1
	5           HOTEL VIVA                                         11           QUINCENAL                                                                                            37
	11          MEDTRAINER SA DE CV                                16           QUINCENAL                                                                                            22
	14          RAXEL                                              19           QUINCENAL                                                                                            6
	13          SOLUCIONES ASFÁLTICAS Y CONSULTORIA S DE RL        18           SEMANAL                                                                                              1
	16          SURFAX                                             21           MENSUAL                                                                                              8
	17          TANQUES Y REMOLQUES TGM SA DE CV                   22           SEMANAL                                                                                              2

*/
GO
