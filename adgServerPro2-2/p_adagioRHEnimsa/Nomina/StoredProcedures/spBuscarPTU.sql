USE [p_adagioRHEnimsa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****************************************************************************************************     
** Descripción  : BUSCAR los PTU's     
** Autor   : Jose Roman   
** Email   : jose.roman@adagio.com.mx    
** FechaCreacion : 2019-04-30    
** Paremetros  :                  
****************************************************************************************************    
HISTORIAL DE CAMBIOS    
Fecha(yyyy-mm-dd) Autor   Comentario    
------------------- ------------------- ------------------------------------------------------------    
  
***************************************************************************************************/   

CREATE PROCEDURE Nomina.spBuscarPTU
(
	@IDPTU int = 0
)
AS
BEGIN
	
	SELECT PTU.IDPTU
		,PTU.IDEmpresa
		,emp.NombreComercial
		,emp.RFC
		,PTU.Ejercicio
		,PTU.DiasMinimosTrabajados
		,PTU.DiasDescontar
		,PTU.DescontarEnfermedadGeneral
		,PTU.CantidadGanancia 
		,PTU.CantidadRepartir 
		,PTU.CantidadPendiente 
		,PTU.EjercicioPago
		,ROW_NUMBER()over(Order by PTU.IDPTU ASC) as ROWNUMBER
	from Nomina.tblPTU PTU
		Inner join RH.tblEmpresa Emp
			on PTU.IDEmpresa = Emp.IdEmpresa
	Where (PTU.IDPTU = @IDPTU)  OR (@IDPTU = 0)
	ORDER BY PTU.Ejercicio desc, Emp.NombreComercial asc
END
GO
