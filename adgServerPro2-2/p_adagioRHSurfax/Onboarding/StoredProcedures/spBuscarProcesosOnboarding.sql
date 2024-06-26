USE [p_adagioRHSurfax]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Onboarding].[spBuscarProcesosOnboarding]  (
@IDProcesoOnboarding int=null,
@IDEmpleadoNuevo int =null,
@IDUsuario int =NULL
)
as
begin
With Proceso as(
  SELECT 
       PO.[IDProcesoOnboarding]
      ,PO.[NombreProceso]
      ,PO.[Terminado]      
      ,PO.[IDsPlantilla]     
      ,NombrePlantilla = ISNULL(
            STUFF(
                (
                    SELECT ', ' + CONVERT(NVARCHAR(100), ISNULL(NombrePlantilla, 'SIN ASIGNAR'))
                    FROM Onboarding.tblPlantillas WITH (NOLOCK)
                    WHERE IDPlantilla IN (SELECT CAST(value AS INT) FROM STRING_SPLIT(PO.IDsPlantilla, ','))
                    ORDER BY NombrePlantilla ASC
                    FOR XML PATH('')
                ), 1, 1, ''
            ),
            'CARGOS NO DEFINIDOS'
        )
      ,[IDEmpleadoEncargado]
      ,ENCARGADO.NOMBRECOMPLETO as [NombreEncargado]
      ,ENCARGADO.ClaveEmpleado as ClaveEmpleado      
      ,UEncargado.IDUsuario as IDUsuarioEncargado
      ,NUEVO.ClaveEmpleado AS ClaveEmpleadoNuevo         
      ,PO.[IDNuevoEmpleado] as IDEmpleadoOnboarding
      ,UNUEVO.IDUsuario as IDUsuarioEmpleadoOnboarding
      ,NUEVO.NOMBRECOMPLETO AS [NombreCompletoOnboarding]
      ,NUEVO.Departamento as DepartamentoOnboarding
      ,NUEVO.IDDepartamento as IDDepartamentoOnboarding
      ,NUEVO.Puesto as PuestoOnboarding
      ,NUEVO.IDPuesto as IDPuestoOnboarding
      ,(Select count(*) from Tareas.tblTareas T
            where IDEstatusTarea = (select IDEstatusTarea from Tareas.tblCatEstatusTareas where IDTipoTablero=3 and IDReferencia=0 and IsEnd = 1 )
                AND PO.IDProcesoOnboarding = T.IDReferencia and T.IDTipoTablero =3) as TareasCompletadas
      ,(Select count(*) from Tareas.tblTareas T
            where IDEstatusTarea != (select IDEstatusTarea from Tareas.tblCatEstatusTareas where IDTipoTablero=3 and IDReferencia=0 and IsEnd = 1 )
                AND PO.IDProcesoOnboarding = T.IDReferencia and T.IDTipoTablero =3) as TareasPendientes
    FROM [Onboarding].[tblProcesosOnboarding] PO    
    LEFT JOIN Rh.tblEmpleadosMaster ENCARGADO on ENCARGADO.IDEmpleado =PO.IDEmpleadoEncargado 
    LEFT JOIN Rh.tblEmpleadosMaster NUEVO ON NUEVO.IDEmpleado = PO.IDNuevoEmpleado
    Left Join Seguridad.tblUsuarios UEncargado on ENCARGADO.IDEmpleado = UEncargado.IDEmpleado
    Left Join Seguridad.tblUsuarios UNUEVO on NUEVO.IDEmpleado = UNUEVO.IDEmpleado
    where  ( IDProcesoOnboarding =@IDProcesoOnboarding or isnull(@IDProcesoOnboarding, 0) = 0) AND
            (PO.IDNuevoEmpleado =@IDEmpleadoNuevo or isnull(@IDEmpleadoNuevo, 0) = 0)
)
    select *, 
        TotalTareas=TareasCompletadas+TareasPendientes, 
       Avance = CASE 
                WHEN (TareasCompletadas + TareasPendientes) = 0 THEN 0
                ELSE CAST((CAST(TareasCompletadas AS DECIMAL(18, 2))) / (TareasCompletadas + TareasPendientes) * 100 AS DECIMAL(18, 2))
            END
    From Proceso
end
GO
