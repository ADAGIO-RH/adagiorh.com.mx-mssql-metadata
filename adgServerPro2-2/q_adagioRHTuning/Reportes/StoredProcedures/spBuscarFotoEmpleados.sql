USE [q_adagioRHTuning]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spBuscarFotoEmpleados](
    @ClaveEmpleado VARCHAR(10),          
	@IDEmpleado  Int,  
	@IDUsuario int = null          
) AS          
BEGIN          
	select             
		em.IDEmpleado            
		,em.ClaveEmpleado            
		,em.NOMBRECOMPLETO       
		,case when FT.ClaveEmpleado IS NULL then (REPLACE(cg.Valor,'Empleados/','nofoto.jpg')) else (cg.Valor + em.ClaveEmpleado+'.jpg') END AS Foto                 
	from rh.tblEmpleadosMaster em with (nolock)  
		left join RH.tblFotosEmpleados FT with (nolock) on EM.IDEmpleado = FT.IDEmpleado                      
		Cross Apply App.tblConfiguracionesGenerales cg with (nolock)          
	where (EM.IDEmpleado in (@IDEmpleado) or em.ClaveEmpleado = @ClaveEmpleado) and cg.IDConfiguracion = 'PathFotos'      
END
GO
