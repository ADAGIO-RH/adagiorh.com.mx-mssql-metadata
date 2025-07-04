USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE RH.spBuscarEmpleadoCredencial --20340
(
	@IDEmpleado int
)
AS
BEGIN
SELECT   

   em.IDEmpleado  
  ,em.ClaveEmpleado  
  ,em.NOMBRECOMPLETO  
  ,em.Puesto  
  ,em.Departamento  
  ,em.Sucursal  
  ,em.IMSS
  ,em.RFC
  ,em.CURP
  ,FBE.NombreCompleto NombreEmergencia
  ,ISNULL(FBE.TelefonoCelular,ISNULL(FBE.TelefonoMovil,'')) Telefono
  ,cg.Valor + em.ClaveEmpleado+'.jpg' as Foto
FROM rh.tblEmpleadosMaster em  
	left join RH.TblFamiliaresBenificiariosEmpleados FBE
		on FBE.IDEmpleado = EM.IDEmpleado
			and FBE.Emergencia = 1
	Cross Apply App.tblConfiguracionesGenerales cg
where EM.IDEmpleado = @IDEmpleado
	and cg.IDConfiguracion = 'PathFotos'
END
GO
