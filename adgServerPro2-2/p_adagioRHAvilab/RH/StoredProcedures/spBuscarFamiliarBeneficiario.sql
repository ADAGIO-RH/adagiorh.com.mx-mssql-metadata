USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar Familiares y Beneficiarios
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-06-08
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc [RH].[spBuscarFamiliarBeneficiario] (
    @IDFamiliarBenificiarioEmpleado int  = 0 
    ,@IDEmpleado int = 0 
) as
    select 
	    fbe.IDFamiliarBenificiarioEmpleado
	   ,fbe.IDEmpleado
	   ,fbe.IDParentesco
	   ,JSON_VALUE(cp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion'))as Parentesco
	   ,fbe.NombreCompleto
	   ,fbe.FechaNacimiento
	   ,fbe.Sexo
	   ,fbe.TelefonoMovil
	   ,fbe.TelefonoCelular
	   ,isnull(fbe.Emergencia,cast(0 as bit)) as Emergencia
	   ,isnull(fbe.Beneficiario,cast(0 as bit)) as Beneficiario
	   ,isnull(fbe.Dependiente,cast(0 as bit)) as Dependiente
	   ,isnull(fbe.Porcentaje,cast(0 as decimal(5,2))) as Porcentaje
    from [RH].[TblFamiliaresBenificiariosEmpleados] fbe
	   join [RH].[TblCatParentescos] cp on fbe.IDParentesco = cp.IDParentesco
	WHERE  (fbe.IDEmpleado = @IDEmpleado)
		  or (fbe.IDFamiliarBenificiarioEmpleado = @IDFamiliarBenificiarioEmpleado)
GO
