USE [p_adagioRHLya]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Insertar / Actualizar Encuestas de Norma035
** Autor			: Denzel Ovando
** Email			: denzel.ovando@adagio.com.mx
** FechaCreacion	: 2020-06-17
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/
CREATE proc [Norma035].[spIUEncuesta](
@IDEncuesta int
,@FechaIni date
,@FechaFin date
,@IDTipoEncuesta int
,@TodaEmpresa bit
,@IDEntidad int
,@Cantidad int
,@FrecuenciaRecordatorioDias int
,@EsAnonimo int
,@Estatus int
,@IDUsuario int
) as


	if (isnull(@IDEncuesta,0) = 0 or @IDEncuesta is null)
	begin
		insert into [Norma035].[tblEncuestas] (FechaIni ,FechaFin ,IDTipoEncuesta ,TodaEmpresa ,IDEntidad ,Cantidad ,FrecuenciaRecordatorioDias ,EsAnonimo ,Estatus)
		values (@FechaIni ,@FechaFin ,@IDTipoEncuesta ,@TodaEmpresa ,@IDEntidad ,@Cantidad ,@FrecuenciaRecordatorioDias ,@EsAnonimo ,@Estatus);
	end else
	begin
		update [Norma035].[tblEncuestas]
		set 
		FechaIni                     = @FechaIni
		,FechaFin                    = @FechaFin
		,IDTipoEncuesta              = @IDTipoEncuesta
		,TodaEmpresa                 = @TodaEmpresa
		,IDEntidad                   = @IDEntidad
		,Cantidad                    = @Cantidad
		,FrecuenciaRecordatorioDias  = @FrecuenciaRecordatorioDias
		,EsAnonimo                   = @EsAnonimo
		,Estatus                     = @Estatus
		where IDEncuesta = @IDEncuesta	

	end


	--Exec [Evaluacion360].[spBuscarPreguntas] @IDPregunta = @IDPregunta
GO
