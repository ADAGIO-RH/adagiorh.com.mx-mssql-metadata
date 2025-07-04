USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Emmanuel Contreras
-- Create date: 2022-05-19
-- Description:	procedimiento para reemplazar las palabras clave en documentos
--				de reclutamiento
-- [Reclutamiento].[spPlantillaCuerpo] 1
-- =============================================
CREATE PROCEDURE [Reclutamiento].[spPlantillaCuerpo]
	(
		@IDCandidatoPlaza int
	)
AS
BEGIN
	DECLARE @Counter INT , @MaxId INT, 
		@IDPlantilla INT,
		@IDCandidato int,
		@IDReclutador int = 1 ,
		@IDPlaza int = 0,
		@IDProceso int,
        @Campo varchar(max),
		@Tabla varchar(max),
		@Contenido varchar(max),
		@Asunto varchar(max),
		@KeyPair varchar(max)

SET NOCOUNT ON

	declare @tblKeyPair table(
			[KEY] varchar(max),
			[VALUE] varchar(max)
			)

	declare @tblPlaza table(
		IDTipoConfiguracionPlaza varchar(max),
		TipoConfiguracionPlaza varchar(max),
		Configuracion varchar(max),
		Valor int,
		descripcion varchar(max),
		Orden int
	)
	
 -- Obtenemos los detalles de la candidatura
	SELECT       
		@IDCandidato = IDCandidato, 
		@IDProceso =  IDProceso,
		@IDPlaza = IDPlaza
	FROM          
		Reclutamiento.tblCandidatoPlaza 
	where
		IDCandidatoPlaza = @IDCandidatoPlaza
 
	IF OBJECT_ID('TEMPDB..#tempPlantilla') is not null drop table #tempPlantilla;

	create table #tempPlantilla (
		IDPlaza int, 
		Contenido varchar(max),
		Asunto varchar(max)
	 )

-- Buscamos la plantilla en función del estatus seleccionado y seteamos el contenido y el asunto
	insert into #tempPlantilla
	select @IDPlaza, p.Contenido,  p.Asunto 
	from Reclutamiento.tblPlantillas p
	left join Reclutamiento.tblCatEstatusProceso e on p.IDPlantilla = e.IDPlantilla	
	where e.IDEstatusProceso = @IDProceso

	-- Obtenemos los contadores 
	SELECT @Counter = min(IDCamposDeBusqueda) , @MaxId = max(IDCamposDeBusqueda) 
	FROM [Reclutamiento].[tblCamposDeBusqueda]
  
	WHILE(@Counter IS NOT NULL
		  AND @Counter <= @MaxId)
	BEGIN
        
	   SELECT @Campo = Campo, @Tabla = Tabla
	   FROM [Reclutamiento].[tblCamposDeBusqueda] WHERE IDCamposDeBusqueda = @Counter
    
	   set @KeyPair = CONCAT(@Tabla,@Campo)

	   --insert  @tblKeyPair 
	   --exec[Reclutamiento].[spBuscarPlantillaLlaveValor] @IDCandidato, @IDReclutador, @Tabla,@Campo

	   update p
		set Contenido = cast(replace(cast(Contenido as varchar(max)), 
								(select top 1 isnull([KEY],'') from @tblKeyPair), 
								(select top 1 isnull([VALUE],'') from @tblKeyPair)) as text)
		,Asunto = cast(replace(cast(Asunto as varchar(max)),  
								(select top 1 isnull([KEY],'') from @tblKeyPair), 
								(select top 1 isnull([VALUE],'') from @tblKeyPair)) as text)
		from #tempPlantilla p
		cross apply @tblKeyPair k
		where k.[KEY] is not null

	  delete from @tblKeyPair

	   SET @Counter  = @Counter  + 1   
	END

	select @IDPlaza as IDPlaza, Contenido,Asunto from #tempPlantilla
END
GO
