USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar los distintos objetos a los que puedo hacer referencia el TipoReferencia según el IDReferencia
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-02-12
** Paremetros		:              

TipoReferencia:
            0 : Catálogo
            1 : Asignado a una Proyecto
            2 : Asignado a un colaborador
            3 : Asignado a un puesto
            4 : Asignado a una Prueba final para responder


** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc [Evaluacion360].[spBuscarInfoPorTipoReferencia](
	@TipoReferencia int 
	,@IDReferencia	int 
) as
		if object_id('tempdb..#tempRespuesta') is not null drop table #tempRespuesta;

		create table #tempRespuesta (
			ID int
			,Codigo varchar(20)
			,Nombre varchar(max)
			,Descripcion nvarchar(max)
			,Tipo varchar(100)
			,TextoCopiando varchar(255)
		);

		if (@TipoReferencia = 1)
		begin
			insert #tempRespuesta
			select IDProyecto,null as Codigo,Nombre,Descripcion,'Proyecto','Copiando al proyecto: '+coalesce(Nombre,'')
			from [Evaluacion360].[tblCatProyectos] with (nolock)
			where IDProyecto = @IDReferencia
		end else
		if (@TipoReferencia = 2)
		begin
			insert #tempRespuesta
			select IDEmpleado,ClaveEmpleado,NOMBRECOMPLETO,Puesto,'Colaborador','Copiando al colaborador: '+coalesce(NOMBRECOMPLETO,'')
			from [RH].[tblEmpleadosMaster] with (nolock)
			where IDEmpleado = @IDReferencia
		end else
		if (@TipoReferencia = 3)
		begin
			insert #tempRespuesta
			select IDPuesto,Codigo,Descripcion, DescripcionPuesto,'Puesto','Copiando al puesto: '+coalesce(Descripcion,'')
			from [RH].[tblCatPuestos] with (nolock)
			where IDPuesto = @IDReferencia
		end;

		select *
		from #tempRespuesta
GO
