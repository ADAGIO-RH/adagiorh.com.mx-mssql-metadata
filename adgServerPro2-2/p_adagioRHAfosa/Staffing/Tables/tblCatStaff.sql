USE [p_adagioRHAfosa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Staffing].[tblCatStaff](
	[IDStaff] [int] IDENTITY(1,1) NOT NULL,
	[IDSucursal] [int] NULL,
	[IDDepartamento] [int] NULL,
	[IDPuesto] [int] NULL,
	[IDPorcentaje] [int] NULL,
	[Cantidad] [int] NULL,
 CONSTRAINT [Pk_StaffingtblCatStaff_IDStaff] PRIMARY KEY CLUSTERED 
(
	[IDStaff] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Staffing].[tblCatStaff]  WITH CHECK ADD  CONSTRAINT [FK_StaffingtblCatStaff_RHtblCatDepartamentos_IDDepartamento] FOREIGN KEY([IDDepartamento])
REFERENCES [RH].[tblCatDepartamentos] ([IDDepartamento])
GO
ALTER TABLE [Staffing].[tblCatStaff] CHECK CONSTRAINT [FK_StaffingtblCatStaff_RHtblCatDepartamentos_IDDepartamento]
GO
ALTER TABLE [Staffing].[tblCatStaff]  WITH CHECK ADD  CONSTRAINT [FK_StaffingtblCatStaff_RHtblCatPuestos_IDPuesto] FOREIGN KEY([IDPuesto])
REFERENCES [RH].[tblCatPuestos] ([IDPuesto])
GO
ALTER TABLE [Staffing].[tblCatStaff] CHECK CONSTRAINT [FK_StaffingtblCatStaff_RHtblCatPuestos_IDPuesto]
GO
ALTER TABLE [Staffing].[tblCatStaff]  WITH CHECK ADD  CONSTRAINT [FK_StaffingtblCatStaff_RHtblCatSucursales_IDSucursal] FOREIGN KEY([IDSucursal])
REFERENCES [RH].[tblCatSucursales] ([IDSucursal])
GO
ALTER TABLE [Staffing].[tblCatStaff] CHECK CONSTRAINT [FK_StaffingtblCatStaff_RHtblCatSucursales_IDSucursal]
GO
ALTER TABLE [Staffing].[tblCatStaff]  WITH CHECK ADD  CONSTRAINT [FK_StaffingtblCatStaff_StaffingtblCatPorcentajes_IDPorcentaje] FOREIGN KEY([IDPorcentaje])
REFERENCES [Staffing].[tblCatPorcentajes] ([IDPorcentaje])
GO
ALTER TABLE [Staffing].[tblCatStaff] CHECK CONSTRAINT [FK_StaffingtblCatStaff_StaffingtblCatPorcentajes_IDPorcentaje]
GO
