USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc [Evaluacion360].[spBuscarEscalaValoracionProyectoAsString](
	@IDProyecto int
	,@IDUsuario int
) as

	select ISNULL( 
					STUFF(
							(   
								SELECT '     '+ CONVERT(NVARCHAR(100), Nombre) +': '+ cast(Valor as varchar(10)) 
								FROM [Evaluacion360].[tblEscalasValoracionesProyectos]
								WHERE IDProyecto = @IDProyecto
								ORDER BY isnull(Valor,0) asc
								FOR xml path('')
							)
						, 1
						, 1
						, ''
					), 
					'Valores de la escala no definidos'
				) as Escala
GO
