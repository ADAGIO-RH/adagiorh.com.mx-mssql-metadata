USE [p_adagioRHAlleiva]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [Evaluacion360].[spBuscarCatEscalaValoracion](
	@IDEscalaValoracion int = 0
) as
	select e.IDEscalaValoracion
			,e.Nombre
			,Escala = ISNULL( STUFF(
							(   SELECT ', ('+ cast(Valor as varchar(10))+') '+ CONVERT(NVARCHAR(100), Nombre) 
								FROM [Evaluacion360].[tblDetalleEscalaValoracion] 
								WHERE IDEscalaValoracion = e.IDEscalaValoracion 
								ORDER BY isnull(valor,0) desc
								FOR xml path('')
							)
							, 1
							, 1
							, ''), 'Valores de la escala no definidos')
	from [Evaluacion360].[tblCatEscalaValoracion] e
	where e.IDEscalaValoracion = @IDEscalaValoracion or @IDEscalaValoracion = 0
	ORDER BY e.Nombre desc
GO
