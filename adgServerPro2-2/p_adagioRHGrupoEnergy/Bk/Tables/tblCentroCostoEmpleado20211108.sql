USE [p_adagioRHGrupoEnergy]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblCentroCostoEmpleado20211108](
	[IDCentroCostoEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDCentroCosto] [int] NOT NULL,
	[FechaIni] [date] NOT NULL,
	[FechaFin] [date] NOT NULL
) ON [PRIMARY]
GO
