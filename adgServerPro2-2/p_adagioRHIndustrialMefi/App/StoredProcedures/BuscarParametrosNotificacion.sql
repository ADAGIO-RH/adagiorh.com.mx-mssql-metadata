USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [App].[BuscarParametrosNotificacion](
	@IDNotificacion int
) as
	declare @vars nvarchar(max)
		,@xml xml
	;
	--@vars nvarchar(max) = '4/7:RF_Z01_Temp:ColAvg,10/13:RF_Z02_Temp:ColAvg,16/19:RF_Z03_Temp:ColAvg,22/25:RF_Z04_Temp:ColAvg,28/31:RF_Z05_Temp:ColAvg,34/37:RF_Z06_Temp:ColAvg,46/49:RF_Z07_Temp:ColAvg,52/55:RF_Z08_Temp:ColAvg,58/61:RF_Z09_Temp:ColAvg,64/67:RF_Z10_Temp:ColAvg,70/73:RF_Z11_Temp:ColAvg,76/79:RF_Z12_Temp:ColAvg,40:RF_Z13_Temp:ColAvg'
	--@vars nvarchar(max)= 'NombreColaborador|ADMINISTRADOR ADMIN,Cuenta|admin,URLActivacion|http://201.156.176.10:9999/login/ActivarCuenta?key=TXQ1MXFGVVZFYTZ3K2NNR0hSRDNnZmY4YWYrZk80eXBMU2IybU53U2RKWT06aW5mb0BhZGFnaW8uY29tLm14OjU8'

	select @xml = Parametros
	from [App].[tblNotificaciones]
	where IDNotifiacion = @IDNotificacion

	SELECT  
		Tbl.Col.value('ID[1]', 'int') as ID,  
		Tbl.Col.value('Variable[1]', 'varchar(max)')as Variable,  
		Tbl.Col.value('Valor[1]', 'varchar(max)')as  Valor
	FROM   @xml.nodes('//row') Tbl(Col)
 
	--IF OBJECT_ID('tempdb..#parserVar') IS NOT NULL
	--	DROP TABLE #parserVar

	--IF OBJECT_ID('tempdb..#parserVarAvg') IS NOT NULL
	--	DROP TABLE #parserVarAvg;
 
	--IF OBJECT_ID('tempdb..#parserVarMapping') IS NOT NULL
	--	DROP TABLE #parserVarMapping;

	--create table #parserVarMapping(
	--	ID int identity(1,1) not null,
	--	Variable varchar(512),
	----	TipoDato varchar(512),
	--	Valor varchar(255)
	--)

	--insert into #parserVarMapping (Variable)
	--select Item from App.Split(@vars,',')

	--update #parserVarMapping
	--   set
	--	Variable = (select top 1 Item from App.Split(Variable,'|') where ID = 1),
	----	TipoDato = (select top 1 Item from App.Split(Variable,':') where ID = 3),
	--	Valor = (select top 1 Item from App.Split(Variable,'|') where ID = 2)

	--select * from #parserVarMapping
GO
