USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Staffing].[tblCatStaff](
	[IDStaff] [int] IDENTITY(1,1) NOT NULL,
	[IDMapeo] [int] NULL,
	[IDPorcentaje] [int] NULL,
	[Cantidad] [int] NULL,
 CONSTRAINT [Pk_StaffingtblCatStaff_IDStaff] PRIMARY KEY CLUSTERED 
(
	[IDStaff] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Staffing].[tblCatStaff]  WITH CHECK ADD  CONSTRAINT [FK_StaffingtblCatStaff_StaffingtblCatMapeoPuestos_IDMapeo] FOREIGN KEY([IDMapeo])
REFERENCES [Staffing].[tblCatMapeoPuestos] ([IDMapeo])
ON DELETE CASCADE
GO
ALTER TABLE [Staffing].[tblCatStaff] CHECK CONSTRAINT [FK_StaffingtblCatStaff_StaffingtblCatMapeoPuestos_IDMapeo]
GO
ALTER TABLE [Staffing].[tblCatStaff]  WITH CHECK ADD  CONSTRAINT [FK_StaffingtblCatStaff_StaffingtblCatPorcentajes_IDPorcentaje] FOREIGN KEY([IDPorcentaje])
REFERENCES [Staffing].[tblCatPorcentajes] ([IDPorcentaje])
GO
ALTER TABLE [Staffing].[tblCatStaff] CHECK CONSTRAINT [FK_StaffingtblCatStaff_StaffingtblCatPorcentajes_IDPorcentaje]
GO
