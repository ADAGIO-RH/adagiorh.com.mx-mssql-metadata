USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	CREATE PROCEDURE [Norma35].[spResultadosEncuestaEmpleados](
        @IDEncuestaEmpleado int
    )
    AS
    Begin
        select  distinct
                C.Descripcion as Categoria
                ,D.Descripcion as Dominio
			    ,CDE.CalificacionLiteral  as Resultado    
                ,D.IDDominio                             
                from Norma35.tblEncuestasEmpleados EE
                    inner join Norma35.tblEncuestas E
                        on EE.IDEncuesta = E.IDEncuesta
                    inner join Norma35.tblCatGrupos G
                        on G.TipoReferencia = 2 and G.IDReferencia = EE.IDEncuestaEmpleado
                    inner join Norma35.tblCatPreguntas p
                        on p.IDCatGrupo = g.IDCatGrupo
                    inner join Norma35.tblcatCategorias C
                        on P.IDCategoria = C.IDCategoria
                    Inner join Norma35.tblCalificacionCategoriaEncuestas CCE
                        on C.IDCategoria = CCE.IDCategoria
                        and CCE.IDCatEncuesta = E.IDCatEncuesta
                    Inner join Norma35.tblCatDominios D
                    on P.IDDominio = D.IDDominio
                    Inner join Norma35.tblCalificacionDominioEncuestas CDE
                        on D.IDDominio = CDE.IDDominio
                        		and CDE.IDCatEncuesta = E.IDCatEncuesta           
                    inner join Norma35.tblRespuestasPreguntas rp
                        on p.IDCatPregunta = rp.IDCatPregunta                                
                where ee.IDEncuestaEmpleado = @IDEncuestaEmpleado
                Group by C.Descripcion, 
                            CCE.Inicio, 
                            CCE.Fin,
                            CCE.CalificacionLiteral, 
                            D.Descripcion,
                            CDE.Inicio, 
                            CDE.Fin, 
                            CDE.CalificacionLiteral,
                            D.IDDominio  
                Having SUM(rp.ValorFinal) Between CCE.Inicio and CCE.Fin 
                    AND SUM(rp.ValorFinal) Between CDE.Inicio and CDE.Fin
                ORDER BY D.Descripcion
    END

    -- select * from Norma35.tblCalificacionDominioEncuestas 
    -- select * from Norma35.tblCalificacionCategoriaEncuestas
GO
