USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Insertar / Actualizar Tipos de Preguntas
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-09-25
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc [Evaluacion360].[spIUTipoPregunta](
	 @IDTipoPregunta int			
	,@TipoPregunta varchar(50)	
	,@Descripcion nvarchar(max)
	,@TiempoEstimadoRespuesta int
	,@IDUnidadDeTiempo int		
	--,@IDTemplate varchar(255)
	,@IDUsuario int
    	,@Traduccion nvarchar(max)
) as
	if (@IDTipoPregunta <> 0)
	begin
		update [Evaluacion360].[tblCatTiposDePreguntas]
			set TipoPregunta = @TipoPregunta
				,Descripcion = @Descripcion
				,TiempoEstimadoRespuesta = @TiempoEstimadoRespuesta
				,IDUnidadDeTiempo = @IDUnidadDeTiempo
                ,Traduccion			= case when ISJSON(@Traduccion) > 0 then @Traduccion else null end
		where IDTipoPregunta = @IDTipoPregunta
	end;

	exec [Evaluacion360].[spBuscarTiposPreguntas] @IDTipoPregunta
GO
