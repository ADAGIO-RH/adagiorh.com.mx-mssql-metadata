USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca empleados por Nombre y/o clave Empleado
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-12-24
** Paremetros		:              
	@tipo = 1		: Vigentes
			0		: No Vigentes
			Null	: Ambos

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2019-05-10			Aneudy Abreu		Se agregó el parámetro @IDUsuario y el JOIN a la tabla de 
										Seguridad.tblDetalleFiltrosEmpleadosUsuarios
2022-12-02			Alejandro Paredes	Se corrigio el campo email y se obtienen unicamente los campos necesarios
***************************************************************************************************/
CREATE PROC [RH].[spFilterEmpleadosEncargados](  
	@IDUsuario INT = 0,
	@filter VARCHAR(1000),
	@tipo INT = NULL
) AS
	--DECLARE   
    --@FechaIni DATE = '1900-01-01',  
    --@Fechafin DATE = '9999-12-31',  
    --@empleados [RH].[dtEmpleados]  
    --,@dtFiltros [Nomina].[dtFiltrosRH];  
  
    --INSERT INTO @dtFiltros(Catalogo,Value)  
    --SELECT 'NombreClaveFilter', @filter  
  
	--INSERT INTO @empleados  
    --EXEC [RH].[spBuscarEmpleados]   
    --@IDUsuario = @IDUsuario  
    --,@dtFiltros = @dtFiltros  
  

	SELECT E.IDEmpleado,
		   E.ClaveEmpleado,
		   E.NombreCompleto,
		   E.Departamento,
 		   E.Sucursal,
		   E.Puesto,
		   E.IDTipoNomina,
		   Email = CASE 
					WHEN CONTAC.[Value] IS NOT NULL
						THEN CONTAC.[Value] 
					WHEN U.Email IS NOT NULL 
						THEN U.Email 
					ELSE '' 
				   END  
    from [RH].[tblEmpleadosMaster] E WITH(NOLOCK)
		INNER JOIN [SEGURIDAD].[tblDetalleFiltrosEmpleadosUsuarios] DFE WITH(NOLOCK) ON DFE.IDEmpleado = E.IDEmpleado AND DFE.IDUsuario = @IDUsuario
		LEFT JOIN [SEGURIDAD].[tblUsuarios] U ON E.IDEmpleado = U.IDEmpleado
		LEFT JOIN (SELECT *
				   FROM RH.tblContactoEmpleado CE
						LEFT JOIN RH.tblCatTipoContactoEmpleado CTCE ON CE.IDTipoContactoEmpleado = CTCE.IDTipoContacto AND CTCE.IDMedioNotificacion = 'Email'
		) AS CONTAC ON CONTAC.IDEmpleado = E.IDEmpleado
    WHERE [ClaveNombreCompleto] LIKE '%' + @filter + '%' AND
		  (E.Vigente = CASE
						WHEN @tipo IS NOT NULL 
							THEN @tipo 
							ELSE e.Vigente 
						END)
    ORDER BY ClaveEmpleado ASC

	--SELECT * FROM RH.tblCatTipoContactoEmpleado
GO
